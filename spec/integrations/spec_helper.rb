#shared contexts for integrations
require 'spec_helper'
require 'logger'
require 'yaml'
require 'sequel'
Sequel.extension :migration 

Loggers = []
#Loggers << Logger.new($stdout)

def connect_db(env)
  config = YAML.load_file(File.join('config','database.yml'))
  Sequel.connect(config[env.to_s], :loggers => Loggers)
end

def config_bus(env)
  YAML.load_file(File.join('config','amqp.yml'))[env.to_s] 
end

def set_uuid(session, object, uuid)
  session << object
  ur = session.new_uuid_resource_for(object)
  ur.send(:uuid=, uuid)
end

shared_context "sequel store" do
  let(:db) { Sequel.sqlite '' }
  let(:store) { Lims::Core::Persistence::Sequel::Store.new(db) }
  before(:each) { Sequel::Migrator.run(db, 'db/migrations') }
  include_context "initialize taxonomies table"
end

shared_context "initialize taxonomies table" do
  before(:each) do
    db[:taxonomies].insert(:taxon_id => 9606, :name => "Homo sapiens", :type => "scientific name")
    db[:taxonomies].insert(:taxon_id => 9606, :name => "human", :type => "common name")
  end
end

shared_context 'use core context service' do
  let(:db) { connect_db(:test) }
  let(:store) { Lims::Core::Persistence::Sequel::Store.new(db) }
  let(:message_bus) { mock(:message_bus).tap { |m| m.stub(:publish) } } 
  let(:context_service) { Lims::Api::ContextService.new(store, message_bus) }
  include_context "initialize taxonomies table"

  before(:each) do
    app.set(:context_service, context_service)
  end
  #This code is cleaning up the DB after each test case execution
  after(:each) do
    # list of all the tables in our DB
    %w{samples taxonomies dna rna cellular_material genotyping uuid_resources}.each do |table|
      db[table.to_sym].delete
    end
    db.disconnect
  end
end

shared_context 'JSON' do
  before(:each) {
    header('Accept', 'application/json')
    header('Content-Type', 'application/json')
  }
end
