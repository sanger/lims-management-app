require 'open-uri'
#require 'open_uri_redirections'
require 'tmpdir'
require 'sequel'
require 'digest/md5'
require 'fileutils'
require 'zlib'
require 'rubygems/package'
require 'yaml'

require 'logger'

$stdout.sync = true

def db_init
  config_environment = @config["db_environment"] || ENV["LIMS_MANAGEMENT_APP_ENV"]
  @db_config = YAML.load_file(File.join("config", "database.yml"))
  db_adapter = @db_config[config_environment]["adapter"]
  database = @db_config[config_environment]["database"]
  @db = (db_adapter == "sqlite") ? Sequel.sqlite(database) : Sequel.connect(@db_config[config_environment])

  @db.create_table :tmp_taxonomies do
    primary_key :id
    Integer :taxon_id
    String :name
    String :type
  end

  @db.add_index :tmp_taxonomies, :taxon_id
  @db.add_index :tmp_taxonomies, :name
end

def initialize_app
  @logger = Logger.new($stdout)
  @logger.level = Logger::DEBUG

  @config = YAML.load_file(File.join("config", "taxonomy.yml"))
  @url = @config["url"]
  @types_to_process = @config["types_to_process"]
  @taxdump_file_name = @config["taxdump_file_name"]
  @taxonomy_names_file_name = @config["taxonomy_names_file_name"]
  @nb_of_bulk_inserts = @config["nb_of_bulk_inserts"]
  @test = @config["test"]
  @path = Dir.mktmpdir

  # database initialization
  db_init
end

def execution_completed
  @db.drop_table(:tmp_taxonomies)
  @db.disconnect
  FileUtils.rm_r @path unless @test || !@test.nil?
end

def save_file(filename, url)
  began_at = Time.now
  @logger.info("Started saving temporary file #{filename} from #{url} into the following location: #{@path}")
  system("wget #{url} -O #{@path}/#{filename} --no-check-certificate")
  @logger.info("Now calculating time...")
  spent_time = Time.now - began_at
  @logger.info("Temporary file #{filename} has been created in #{spent_time.to_s} seconds in the following location: #{@path}")
end

def get_original_taxdump_md5
  save_file(@taxdump_file_name + ".md5", @url + @taxdump_file_name + ".md5")

  md5_orig_file = File.open("#{@path}/#{@taxdump_file_name}.md5", 'r') { |f| f.read }
  @md5_cheksum = md5_orig_file.slice!(0, md5_orig_file.index(" "))
end

def get_taxonomy_file_md5
  save_file(@taxdump_file_name, @url + @taxdump_file_name)
  @md5_taxonomy_file = Digest::MD5.file("#{@path}/#{@taxdump_file_name}").hexdigest
end

def valid_md5
  get_original_taxdump_md5
  get_taxonomy_file_md5
  @md5_cheksum == @md5_taxonomy_file
end

def save_entry(entry)
  File.open("#{@path}/#{@taxonomy_names_file_name}", "wb") do |names|
    names.write(entry.read)
  end
end

def download_and_unzip_taxonomy_file
  if valid_md5
    @logger.info("The downloaded #{@taxdump_file_name} MD5 checksum (#{@md5_cheksum}) was valid.")
    Gem::Package::TarReader.new(Zlib::GzipReader.open("#{@path}/#{@taxdump_file_name}")).each do |entry|
      save_entry(entry) if entry.full_name == @taxonomy_names_file_name
    end
    @logger.info("Temporary file #{@taxonomy_names_file_name} has been created in the following location: #{@path}")
    true
  else
    false
  end
end

def inserting_bulk_data(ds, data_to_process)
  # I had to slice multi insert to several part,
  # because MySQL has timed out with a very large amount of bulk inserts
  while(!data_to_process.empty?) do
    data_to_insert = data_to_process.slice!(0, @nb_of_bulk_inserts)
    ds.multi_insert(data_to_insert)
    print '.'
  end
end

def insert_data_to_tmp_taxonomy_table
  began_at = Time.now
  @logger.info("Started inserting data to tmp_taxonomies table")
  ds = @db[:tmp_taxonomies]
  data_to_process = []
  File.open("#{@path}/#{@taxonomy_names_file_name}").each_line do |line|
    element = line.gsub(/\t/,'').split('|')
    type = element[3]
    data = {}

    if @types_to_process.include?(type)
      data[:taxon_id] = element[0]
      data[:name] = element[1]
      data[:type] = type
      data_to_process << data
    end

    if ((data_to_process.length % @nb_of_bulk_inserts) == 0)
      inserting_bulk_data(ds, data_to_process)
      data_to_process = []
    end
  end

  inserting_bulk_data(ds, data_to_process)

  spent_time = Time.now - began_at
  @logger.info("Finished inserting data to tmp_taxonomies table in #{spent_time.to_s} seconds.")
end

def process_new_taxonomy_data
  began_at = Time.now
  @logger.info("Started processing new taxonomy data to the taxonomies table.")

  ds_taxonomies = @db[:taxonomies]
  ds_tmp = @db[:tmp_taxonomies]
  today = Date.today.to_s
  @tmp_taxon_ids_for_deletion = []

  # removed taxonomies -> mark them as deleted
  ids_for_mark_deleted = []
  removed_taxonomies = @db["SELECT l.id FROM taxonomies l LEFT JOIN tmp_taxonomies r ON l.taxon_id=r.taxon_id WHERE r.taxon_id IS NULL AND l.deleted IS NULL"].all
  removed_taxonomies.each do |removed_element|
    ids_for_mark_deleted << removed_element[:id]
  end
  unless ids_for_mark_deleted.empty?
    @logger.info("Started processing removed taxonomy data.")
    ds_taxonomies.where('id IN ?', ids_for_mark_deleted).update(:deleted => today)
    @logger.info("Removed taxonomy data has been processed.")
  end

  # new taxonomies -> add them to the taxonomies table
  @logger.info("Started processing new taxonomy data.")
  index = 0
  while true
    new_taxonomies = @db[%Q{
      SELECT r.taxon_id, r.name, r.type
      FROM taxonomies l RIGHT JOIN tmp_taxonomies r ON l.taxon_id=r.taxon_id
      WHERE l.taxon_id IS NULL
      LIMIT #{@nb_of_bulk_inserts} OFFSET #{index * @nb_of_bulk_inserts}
    }].all
    break if new_taxonomies.empty?

    new_taxonomies.each do |new_element|
      new_element[:created] = today
      @tmp_taxon_ids_for_deletion << new_element[:taxon_id]
    end
    inserting_bulk_data(ds_taxonomies, new_taxonomies)
    index += 1
  end
  @logger.info("New taxonomy data has been processed.")

  # process changed elements
  # process changed scientific names
  ids_for_mark_deleted = []
  changed_scientific_elements = []
  changed_scientific_taxonomies =
    @db["SELECT l.id ,r.taxon_id, r.name, r.type FROM taxonomies l INNER JOIN tmp_taxonomies r ON l.taxon_id=r.taxon_id AND l.type = r.type AND l.type ='scientific name' WHERE l.name != r.name AND l.deleted IS NULL"].all
  changed_scientific_taxonomies.each do |changed_element|
    ids_for_mark_deleted << changed_element[:id]

    # creating new element array for bulk insert
    changed_element[:overrides_id] = changed_element.delete(:id)
    changed_element[:created] = today
    changed_scientific_elements << changed_element
  end
  # update the removed scientific record as deleted
  unless ids_for_mark_deleted.empty?
    @logger.info("Started processing removed scientific names.")
    ds_taxonomies.where('id IN ?', ids_for_mark_deleted).update(:deleted => today)
    @logger.info("Removed scientific names has been processed.")
  end
  # insert the new scientific names (changed ones)
  unless changed_scientific_elements.empty?
    @logger.info("Started processing new (changed) scientific names.")
    inserting_bulk_data(ds_taxonomies, changed_scientific_elements)
    @logger.info("Finished processing new (changed) scientific names.")
  end

  # process added common names
  added_common_names = []
  added_common_taxonomies =
    @db["SELECT DISTINCT r.taxon_id, r.name AS new_name, r.type FROM taxonomies l INNER JOIN tmp_taxonomies r ON l.taxon_id=r.taxon_id AND l.type = r.type AND l.type ='common name' WHERE l.name != r.name HAVING new_name NOT IN (SELECT name FROM taxonomies t2 WHERE t2.taxon_id = r.taxon_id)"].all
  added_common_taxonomies.each do |added_element|
    added_element[:name] = added_element.delete(:new_name)
    added_element[:created] = today
    added_common_names << added_element
  end
  # insert newly added common names
  unless added_common_names.empty?
    @logger.info("Started processing newly added common names.")
    inserting_bulk_data(ds_taxonomies, added_common_names)
    @logger.info("Finished processing newly added common names.")
  end

  # process removed common names
  ids_for_mark_deleted = []
  removed_common_taxonomies =
    @db["SELECT DISTINCT l.id FROM taxonomies l INNER JOIN tmp_taxonomies r ON l.taxon_id=r.taxon_id AND l.type ='common name' AND l.name NOT IN (SELECT name from tmp_taxonomies)"].all
  removed_common_taxonomies.each do |removed_element|
    ids_for_mark_deleted << removed_element[:id] unless removed_element[:id].nil?
  end
  # update the removed common names as deleted
  unless ids_for_mark_deleted.empty?
    @logger.info("Started updating the removed common names as deleted.")
    ds_taxonomies.where('id IN ?', ids_for_mark_deleted).update(:deleted => today)
    @logger.info("Finished updating the removed common names as deleted.")
  end

  # reappeared record, which are currently marked as deleted -> set deleted to NULL
  ids_for_unmark_as_deleted = []
  reappeared_common_taxonomies =
    @db["SELECT l.id FROM taxonomies l INNER JOIN tmp_taxonomies r ON l.taxon_id=r.taxon_id AND l.type = r.type AND l.type ='common name' AND l.name = r.name WHERE l.deleted IS NOT NULL"].all
  reappeared_common_taxonomies.each do |reappeared_element|
    ids_for_unmark_as_deleted << reappeared_element[:id] unless reappeared_element[:id].nil?
  end
  # update the reappered record and set the deleted flag as NULL
  unless ids_for_unmark_as_deleted.empty?
    @logger.info("Started updating the reappeared common names as not deleted.")
    ds_taxonomies.where('id IN ?', ids_for_unmark_as_deleted).update(:deleted => nil)
    @logger.info("Finished updating the reappeared common names as not deleted.")
  end

  spent_time = Time.now - began_at
  @logger.info("Finished inserting data to taxonomy table in #{spent_time.to_s} seconds.")
end

def create_update_taxonomy
  initialize_app
  if @test
    valid_file = true
    @path = "./script/data"
  else
    valid_file = download_and_unzip_taxonomy_file
  end

  unless valid_file
    @logger.error("The downloaded #{@taxdump_file_name} MD5 checksum was invalid.")
    @logger.error("The #{@taxdump_file_name} MD5 checksum: #{@md5_taxonomy_file}.")
    @logger.error("The valid MD5 checksum: #{@md5_cheksum}.")
    @logger.error("The new taxonomy names processing has been failed and the database has not been updated!")
    execution_completed
    abort
  else
    insert_data_to_tmp_taxonomy_table
    process_new_taxonomy_data
    execution_completed
    @logger.info("New taxonomy names has been processed and the database has been updated!")
  end
end

create_update_taxonomy
