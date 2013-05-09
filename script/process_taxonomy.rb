require 'open-uri'
require 'tmpdir'
require 'sequel'
require 'digest/md5'
require 'fileutils'
require 'zlib'
require 'rubygems/package'

require 'logger'
require 'rubygems'
require 'ruby-debug'

def db_init
  config_environment = @config["db_environment"]
  @db_config = YAML.load_file(File.join("config", "database.yml"))
  db_adapter = @db_config[config_environment]["adapter"]
  database = @db_config[config_environment]["database"]
  case db_adapter
  when "sqlite"
    @db = Sequel.sqlite(database)
  when "mysql", "mysql2"
    db_user = @db_config[config_environment]["username"]
    db_password = @db_config[config_environment]["password"]
    @db = Sequel.connect(:adapter => db_adapter,
      :user => db_user,
      :database => database,
      :password => db_password)
  else
    @logger.error("Not supported database has been configured!")
    abort
  end
end

def initialize_app
  @logger = Logger.new($stdout)
  @logger.level = Logger::DEBUG

  @config = YAML.load_file(File.join("config", "taxonomy.yml"))
  @url = @config["url"]
  @types_to_process = @config["types_to_process"]
  @taxdump_file_name = @config["taxdump_file_name"]
  @taxonomy_names_file_name = @config["taxonomy_names_file_name"]
  @path = Dir.mktmpdir

  # database initialization
  db_init
end

def execution_completed
  FileUtils.rm_r @path
  @logger.info("New taxonomy names has been processed and the database has been updated!")
end

def save_file(filename, url)
  began_at = Time.now
  @logger.info("Started saving temporary file #{filename} in the following location: #{@path}")
  File.open("#{@path}/#{filename}", "wb") do |taxdump_local|
    open(url, 'rb') do |taxdump_ftp|
      taxdump_local.write(taxdump_ftp.read)
    end
  end
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

def insert_data_to_tmp_taxonomy_table
  began_at = Time.now
  @logger.info("Started inserting data to tmp_taxonomy table")
  ds = @db[:tmp_taxonomies]
  File.open("#{@path}/#{@taxonomy_names_file_name}").each_line do |line|
    element = line.gsub(/\t/,'').split('|')
    type = element[3]

    if @types_to_process.include?(type)
      ds.insert(:taxon_id => element[0], :name => element[1], :type => type)
    end
  end
  spent_time = Time.now - began_at
  @logger.info("Finished inserting data to tmp_taxonomy table in #{spent_time.to_s} seconds.")
end

def process_new_taxonomy_data
  began_at = Time.now
  @logger.info("Started processing new taxonomy data to the taxonomies table.")

  ds_taxonomies = @db[:taxonomies]
  ds_tmp = @db[:tmp_taxonomies]
  @taxon_ids_from_db = @db.fetch("SELECT DISTINCT taxon_id FROM taxonomies").all

  @taxon_ids_from_db.each do |taxon_id_db|
    # taxon_id from the taxonomy table
    existing_taxon_id = taxon_id_db[:taxon_id]

    # select all new taxonomies from the tmp_taxonomies table with the existing_taxon_id
    new_elements = ds_tmp.where(:taxon_id => existing_taxon_id).all

    # check if the element is still exist?
    if new_elements.empty?
      # elements with this taxon id is not existing in the new taxonomy data,
      # so we should mark them as deleted
      ds_taxonomies.where(:taxon_id => existing_taxon_id).update(:deleted => Date.today.to_s)
    else
      new_common_name_ids = []
      new_elements.each do |new_element|
        case new_element[:type]
        when "scientific name"
          old_scientific_elements = ds_taxonomies.where(:taxon_id => existing_taxon_id, :type => 'scientific name').all
          old_scientific_element = old_scientific_elements[0]
          if old_scientific_element[:name] != new_element[:name]
            # update the current record
            ds_taxonomies.where(:id => old_scientific_element[:id]).update(:deleted => Date.today.to_s)

            # insert the new taxonomy
            ds_taxonomies.insert(:overrides_id => old_scientific_element[:id], :taxon_id => new_element[:taxon_id], :name => new_element[:name], :type => new_element[:type], :created => Date.today.to_s)
          end
        when "common name"
          old_common_element = 
            ds_taxonomies.where(:taxon_id => existing_taxon_id, :type => 'common name', :name => new_element[:name]).all
          if old_common_element.empty?
            # add new taxonomy element to the DB
            new_common_element_id = ds_taxonomies.insert(:taxon_id => new_element[:taxon_id], :name => new_element[:name], :type => new_element[:type], :created => Date.today.to_s)
            new_common_name_ids << new_common_element_id
          else
            new_common_name_ids << old_common_element[0][:id]
          end
        end
      end

      # marks the old common name elements as deleted, which not exists in the new taxonomy data
      ds_taxonomies.where(:type => 'common name', :taxon_id => existing_taxon_id).exclude(:id => new_common_name_ids).update(:deleted => Date.today.to_s)

      # deletes the processed record from the temp_taxonomies table
      ds_tmp.where(:taxon_id => existing_taxon_id).delete
    end
  end

  # moves (copy and delete) the remainder taxonomies from the tmp table to the taxonomies table as new ones
  @logger.info("Starts adding the brand new taxonomy data to the taxonomies table.")
  remainder_taxonomies = ds_tmp.all
  remainder_taxonomies.each do |new_taxonomy|
    ds_taxonomies.insert(:taxon_id => new_taxonomy[:taxon_id], 
      :name => new_taxonomy[:name],
      :type => new_taxonomy[:type],
      :created => Date.today.to_s)
    ds_tmp.where(:id => new_taxonomy[:id]).delete
  end

  spent_time = Time.now - began_at
  @logger.info("Finished inserting data to taxonomy table in #{spent_time.to_s} seconds.")
end

def create_update_taxonomy
  initialize_app
  valid_file = download_and_unzip_taxonomy_file

  if valid_file
    insert_data_to_tmp_taxonomy_table
    process_new_taxonomy_data
  else
    @logger.error("The downloaded #{@taxdump_file_name} MD5 checksum was invalid.")
    @logger.error("The #{@taxdump_file_name} MD5 checksum: #{@md5_taxonomy_file}.")
    @logger.error("The valid MD5 checksum: #{@md5_cheksum}.")
  end

  execution_completed
end

create_update_taxonomy
