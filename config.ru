require 'lims-management-app'
require 'logger-middleware'

Lims::Api::Server.configure(:development) do |config|
  require 'lims-api/sequel'
  require 'lims-api/message_bus'
  store = Lims::Api::Sequel::create_store(:development)
  message_bus = Lims::Api::MessageBus::create_message_bus(:development)
  config.set :context_service, Lims::Api::ContextService.new(store, message_bus)
  config.set :base_url, "http://localhost:9292"
end

logger = Logger.new($stdout)

use LoggerMiddleware, logger

run Lims::Api::Server
