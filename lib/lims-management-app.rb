require 'common'

module Lims
  module Core
    NO_AUTOLOAD = true
  end
end

require 'lims-management-app/version'
require 'lims-management-app/sample/all'
require 'lims-management-app/sample-collection/all'

require 'lims-core/persistence/search/all'
require 'lims-api/persistence/search_resource'

require 'lims-api/server'
require 'lims-api/context_service'
require 'lims-api/message_bus'

module Lims
  module ManagementApp

  end
end
