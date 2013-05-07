require 'lims-core/persistence/persistor'

module Lims::ManagementApp
  class Sample
    class SamplePersistor < Lims::Core::Persistence::Persistor
      Model = Sample

      def filter_attributes_on_save(attributes)
        attributes.mash do |k,v|
          case k
          when :dna then [:dna_id, save_component(v)]
          when :rna then [:rna_id, save_component(v)]
          when :cellular_material then [:cellular_material_id, save_component(v)]
          when :genotyping then [:genotyping_id, save_component(v)]
          else [k,v]
          end
        end
      end

      # @param [Object] object
      # @return [Integer]
      # In that case, object is not a Lims::Core::Resource object.
      # Indeed, sample contains DNA/RNA/... data but there are not
      # resources. They are only part of a sample. As a result, we
      # cannot use the @session.id_for!(object) as it only works 
      # with Lims::Core::Resource. Here we try to get an id for that
      # object, if we cannot find it in session, we save the object
      # and get its id.
      def save_component(object)
        return nil unless object
        @session.persistor_for(object).id_for(object) || @session.save(object)
      end

      def filter_attributes_on_load(attributes)
        attributes.mash do |k,v|
          case k
          when :dna_id then [:dna, @session.dna[v]]
          when :rna_id then [:rna, @session.rna[v]]
          when :cellular_material_id then [:cellular_material, @session.cellular_material[v]]
          when :genotyping_id then [:genotyping, @session.genotyping[v]]
          else [k,v]
          end
        end
      end
    end
  end
end
