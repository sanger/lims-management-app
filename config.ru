require 'lims-management-app'
require 'logger-middleware'

Lims::Api::Server.configure(:development) do |config|
  require 'lims-api/sequel'
  require 'lims-api/message_bus'
  store = Lims::Api::Sequel::create_store(:development_mysql)
  backend_application_id = Gem::Specification::load("lims-management-app.gemspec").name
  message_bus = Lims::Api::MessageBus::create_message_bus(:development, backend_application_id)

  sample_collection_conf = YAML.load_file(File.join('config','sample_collection.yml'))
  Lims::ManagementApp::Configuration.set_sample_collection_configuration(sample_collection_conf)

  config.set :context_service, Lims::Api::ContextService.new(store, message_bus)
  config.set :base_url, "http://localhost:9292"
end

logger = Logger.new($stdout)

use LoggerMiddleware, logger

run Lims::Api::Server
