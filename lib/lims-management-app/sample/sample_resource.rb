require 'lims-api/core_resource'
require 'lims-api/struct_stream'

module Lims::ManagementApp
  class Sample
    class SampleResource < Lims::Api::CoreResource

      # @param [Stream] s
      # @param [String] mime_type
      # @param [Bool] without_sample_collections
      def content_to_stream(s, mime_type, without_sample_collections = false)
        object.attributes.each do |k,v|
          next if ["dna", "rna", "cellular_material", "genotyping", "sample_collections"].include?(k.to_s)
          s.add_key k
          s.add_value v
        end

        component_to_stream("dna", object.dna, s, mime_type)
        component_to_stream("rna", object.rna, s, mime_type)
        component_to_stream("cellular_material", object.cellular_material, s, mime_type)
        component_to_stream("genotyping", object.genotyping, s, mime_type)

        # Sample collections are displayed only if a sample is accessed.
        # In fact, in case a sample collection is loaded, we do not want to load:
        # sample collection -> samples -> sample collections but just
        # sample collection -> samples
        unless without_sample_collections
          sample_collections_to_stream(object.sample_collections, s, mime_type)
        end
      end

      private

      # @param [String] key
      # @param [Object] object
      # @param [Stream] s
      # @param [String] mime_type
      def component_to_stream(key, object, s, mime_type)
        if object
          s.add_key key
          hash_to_stream(s, object.attributes, mime_type)
        end
      end

      # @param [Hash] sample_collections
      # @param [Stream] s
      # @param [String] mime_type
      def sample_collections_to_stream(sample_collections, s, mime_type)
        unless sample_collections.nil? || sample_collections.empty?
          s.add_key "sample_collections"
          s.with_array do
            sample_collections.each do |collection|
              encoder = @context.encoder_for(collection, [mime_type])
              s.with_hash do
                encoder.actions_to_stream(s)
                s.add_key :uuid
                s.add_value encoder.object.uuid
                encoder.object.content_to_stream(s, mime_type, true)
              end
            end
          end
        end
      end
    end 
  end
end
