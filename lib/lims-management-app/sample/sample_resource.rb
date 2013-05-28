require 'lims-api/core_resource'
require 'lims-api/struct_stream'

module Lims::ManagementApp
  class Sample
    class SampleResource < Lims::Api::CoreResource

      def content_to_stream(s, mime_type)
        object.attributes.each do |k,v|
          next if ["dna", "rna", "cellular_material", "genotyping"].include?(k.to_s)
          s.add_key k
          s.add_value v
        end

        component_to_stream("dna", object.dna, s, mime_type)
        component_to_stream("rna", object.rna, s, mime_type)
        component_to_stream("cellular_material", object.cellular_material, s, mime_type)
        component_to_stream("genotyping", object.genotyping, s, mime_type)
      end

      module Encoder
        include Lims::Api::CoreResource::Encoder

        def errors
          object.object.persistence_errors
        end
          
        def status
          errors.empty? ? 200 : 400
        end

        def to_stream(s)
          return to_error_stream(s) unless errors.empty?

          s.tap do
            s.with_hash do
              s.add_key object.model_name.to_s
              s.with_hash do
                to_hash_stream(s)
              end
            end
          end
        end

        def to_error_stream(s)
          s.with_hash do
            s.add_key "error"
            s.add_value errors.first
          end
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

      private

      def component_to_stream(key, object, s, mime_type)
        if object
          s.add_key key
          hash_to_stream(s, object.attributes, mime_type)
        end
      end
    end 
  end
end
