require 'lims-api/core_action_resource'
require 'lims-api/struct_stream'

module Lims::ManagementApp
  class Sample
    module BulkSampleResource
      module Encoder
        include Lims::Api::Resource::Encoder

        def errors
          [].tap do |err|
            object.filtered_attributes[:result][:samples].each do |s|
              err << s.persistence_errors.first unless s.persistence_errors.empty?
            end
          end
        end

        def status
          return 422 unless object.action.valid?
          return 400 unless errors.empty?
          200
        end

        def to_stream(s)
          return to_error_stream(s) unless status == 200
          s.tap do
            s.with_hash do
              s.add_key object.name
              s.with_hash do
                actions_to_stream(s)
                object.content_to_stream(s, @mime_type)
              end
            end
          end
        end

        def to_error_stream(s)
          s.with_hash do
            case status
            when 400 then
              s.add_key "error"
              s.add_value errors.first
            when 422 then
              s.add_key :errors
              s.with_hash do
                object.action.errors.keys.each do |k|
                  s.add_key k
                  s.add_value "invalid"
                end
              end
            end
          end
        end

        def url_for_action(action)
          url_for("actions/#{object.name}")
        end
      end

      Encoders = [
        class JsonEncoder
          include Encoder
          include Lims::Api::JsonEncoder
      end
      ]

      def self.encoder_class_map
        Encoders.mash { |k| [k::ContentType, k] }
      end
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
