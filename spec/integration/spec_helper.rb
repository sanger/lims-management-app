require 'lims-management-app'
require 'spec_helper'
require 'lims-api/context_service'
require 'lims-core/persistence/sequel'
require 'logger'

Loggers = []
#Loggers << Logger.new($stdout)
  
def connect_db(env)
  config = YAML.load_file(File.join('config','database.yml'))
  Sequel.connect(config[env.to_s], :loggers => Loggers)
end

def config_bus(env)
  YAML.load_file(File.join('config','amqp.yml'))[env.to_s] 
end

shared_context 'use core context service' do
  let(:db) { connect_db(:test) }
  let(:store) { Lims::Core::Persistence::Sequel::Store.new(db) }
  let(:message_bus) { mock(:message_bus).tap { |m| m.stub(:publish) } } 
  let(:context_service) { Lims::Api::ContextService.new(store, message_bus) }

  before(:each) { app.set(:context_service, context_service) }
  after(:each) do
    %w{samples uuid_resources}.each { |table| db[table.to_sym].delete }
    db.disconnect
  end
end

shared_context 'JSON' do
  before(:each) do
    header('Accept', 'application/json')
    header('Content-Type', 'application/json')
  end
end
