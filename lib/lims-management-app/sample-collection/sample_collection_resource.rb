require 'lims-api/core_resource'
require 'lims-api/struct_stream'

module Lims::ManagementApp
  class SampleCollection
    class SampleCollectionResource < Lims::Api::CoreResource

      # @param [Stream] s
      # @param [String] mime_type
      # @param [Bool] without_samples
      def content_to_stream(s, mime_type, without_samples = false)
        object.attributes.each do |k,v|
          s.add_key k
          s.add_value v
        end

        s.add_key "data"
        s.with_hash do
          object.data.each do |d|
            s.add_key d.key
            s.add_value d.value
          end
        end

        # Samples are displayed only if a sample collection is accessed.
        # In fact, in case we load a sample, we do not want to load:
        # sample -> sample collections -> samples but just 
        # sample -> sample collections
        unless without_samples
          s.add_key "samples"
          s.with_array do
            samples_to_stream(object.samples, s, mime_type, true)
          end
        end
      end

      private

      # @param [Hash] samples
      # @param [Stream] s
      # @param [String] mime_type
      # @param [Bool] without_sample_collections
      def samples_to_stream(samples, s, mime_type, without_sample_collections)
        samples.each do |sample|
          encoder = @context.encoder_for(sample, [mime_type])
          s.with_hash do
            encoder.actions_to_stream(s)
            s.add_key :uuid
            s.add_value encoder.object.uuid
            encoder.object.content_to_stream(s, mime_type, without_sample_collections)
          end
        end
      end
    end 
  end
end
