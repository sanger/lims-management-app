require 'lims-api/core_action_resource'
require 'lims-api/struct_stream'

module Lims::ManagementApp
  class Sample
    module BulkSampleResource
      def object_to_stream(object, s, mime_type, in_hash = true)
        case object
        when Hash
          s.start_hash unless in_hash
          object.each  do |k, v|
            s.add_key k
            object_to_stream(v, s, mime_type, false)
          end
          s.end_hash unless in_hash
        when Lims::Core::Resource
          encoder = @context.encoder_for(object, [mime_type])
          s.with_hash do
            encoder.to_hash_stream(s)
          end
        when Array
          s.with_array do
            object.each do |v|
              object_to_stream(v, s, mime_type, false)
            end
          end
        else
          s.add_value object
        end
      end
      private :object_to_stream
    end

    class BulkCreateSampleResource < Lims::Api::CoreActionResource
      include BulkSampleResource
    end

    class BulkUpdateSampleResource < Lims::Api::CoreActionResource
      include BulkSampleResource
    end

    class BulkDeleteSampleResource < Lims::Api::CoreActionResource
      include BulkSampleResource
    end
  end
end
