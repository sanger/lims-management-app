require 'lims-api/core_resource'
require 'lims-api/struct_stream'

module Lims::ManagementApp
  class SampleCollection
    class SampleCollectionResource < Lims::Api::CoreResource

      # @param [StructStream] s
      # @param [String] mime_type
      # @param [Bool] without_samples
      def content_to_stream(s, mime_type, without_samples = false)
        object.attributes.each do |k,v|
          s.add_key k
          s.add_value v
        end

        s.add_key "data"
        s.with_hash do
          data_to_stream(object.data, s)
        end

        unless without_samples
          s.add_key "samples"
          s.with_array do
            samples_to_stream(object.samples, s, mime_type)
          end
        end
      end

      private

      def data_to_stream(data, s)
        data.each do |d|
          s.add_key d.key
          s.add_value d.value
        end
      end

      def samples_to_stream(samples, s, mime_type)
        samples.each do |sample|
          encoder = @context.encoder_for(sample, [mime_type])
          s.with_hash do
            encoder.to_hash_stream(s)
          end
        end
      end
    end 
  end
end
