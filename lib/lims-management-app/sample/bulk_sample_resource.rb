require 'lims-api/core_action_resource'
require 'lims-api/struct_stream'

module Lims::ManagementApp
  class Sample
    class BulkUpdateSampleResource < Lims::Api::CoreActionResource
    end

    class BulkDeleteSampleResource < Lims::Api::CoreActionResource
    end
  end
end
