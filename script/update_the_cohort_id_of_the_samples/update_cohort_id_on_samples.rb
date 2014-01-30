require 'rest_client'
require 'optparse'
require 'json'
require 'sequel'

require 'rubygems'
require 'ruby-debug'

UPDATE_BY = "uuid"
USERNAME = "user"
@update_file = "/CGaP_Cohort_ID_changes.txt"
@initial_data = []
@update_data = []
@updates = {}

@options = {}
OptionParser.new do |opts|
  opts.on("-u", "--url [URL]")                    { |v| @options[:url] = v}
  opts.on("-d", "--database [CONNECTION_STRING]") { |d| @options[:db_con] = d }
  opts.on("-v", "--verbose")                      { |v| @options[:verbose] = v}
  opts.on("-o", "--output [OUTPUT]")              { |v| @options[:output] = v}
end.parse!

abort "API url is required" unless @options[:url]

def db_init
  if @options[:db_con]
    @db = Sequel.connect(@options[:db_con])
  else
    config_environment = "development_mysql"
    @db_config = YAML.load_file(File.join("config", "database.yml"))
    db_adapter = @db_config[config_environment]["adapter"]
    database = @db_config[config_environment]["database"]
    @db = Sequel.connect(@db_config[config_environment])
  end
end

def process_file
  File.foreach(File.dirname(__FILE__) + @update_file) do |line|
    data = line.chomp.split("\t")
    @initial_data << { :supplier_sample_name => data[0],
                      :old_cohort_id        => data[1],
                      :new_cohort_id        => data[2]}
  end
end

# gets the samples's uuid from the DB
# and create an array for the data tto update the samples
def prepare_data_for_update
  @initial_data.each do |data|
    sample = @db[:samples].join(:uuid_resources, :samples__id => :uuid_resources__key,
                                :uuid_resources__model_class => 'sample',
                                :samples__supplier_sample_name => data[:supplier_sample_name]).first
    if sample
      sample_uuid = dashed_uuid(sample[:uuid])
      @updates[sample_uuid] = { "cohort" => data[:new_cohort_id] }
    end
  end
end

def dashed_uuid(uuid_str)
  uuid_str[0,8] + "-" + uuid_str[8,4] + "-" + uuid_str[12,4] + "-" + uuid_str[16,4] + "-" + uuid_str[20,12]
end

def updates_samples
  parameters = { "bulk_update_sample" => 
    { "user"    => USERNAME,
      "by"      => UPDATE_BY,
      "updates" => @updates
    }
  }
  debugger
  puts parameters.to_json

  response = RestClient.post( @options[:url],
                             parameters.to_json,
                             {'Content-Type' => 'application/json', 'Accept' => 'application/json'})
  puts
  puts response
end

db_init
process_file
prepare_data_for_update
updates_samples

puts
puts "Samples has been updated"

