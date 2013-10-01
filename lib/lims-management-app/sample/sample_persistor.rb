require 'lims-core/persistence/persistor'
require 'lims-core/actions/action'

module Lims::ManagementApp
  class Sample

    UnknownTaxonIdError = Class.new(Lims::Core::Actions::Action::InvalidParameters)
    NameTaxonIdMismatchError = Class.new(Lims::Core::Actions::Action::InvalidParameters)

    class SamplePersistor < Lims::Core::Persistence::Persistor
      Model = Sample

      # TODO : should be in the sample sequel persistor !

      def filter_attributes_on_save(attributes)
        taxon_id = attributes[:taxon_id]
        attributes.reject { |k,v| k == :taxon_id || k == :sample_collections }.mash do |k,v|
          case k
          when :dna then [:dna_id, save_component(v)]
          when :rna then [:rna_id, save_component(v)]
          when :cellular_material then [:cellular_material_id, save_component(v)]
          when :genotyping then [:genotyping_id, save_component(v)]
          when :scientific_name then [:scientific_taxon_id, taxonomy_primary_id(taxon_id, v, "scientific name")]
          when :common_name then [:common_taxon_id, taxonomy_primary_id(taxon_id, v, "common name")]
          else [k,v]
          end
        end
      end

      # @param [Integer] taxon_id
      # @param [String] name
      # @param [String] type
      # @return [Integer,Nil]
      # Return the taxonomy id based on the taxon id, 
      # the name and type in parameters.
      # If an exception is raised, the save is cancelled
      # and the transaction rollbacked.
      def taxonomy_primary_id(taxon_id, name, type)
        if taxon_id && !name.nil? && name.strip != ""
          persistor = @session.persistor_for(:taxonomy)
          raise UnknownTaxonIdError, {:taxon_id => "Taxon ID #{taxon_id} unknown"} unless persistor.valid_taxon_id?(taxon_id, type)

          id = persistor.id_by_taxon_id_and_name(taxon_id, name, type)
          raise NameTaxonIdMismatchError, {type => "Taxon ID #{taxon_id} does not match the #{type} '#{name}'. Do you mean '#{persistor.name_by_taxon_id(taxon_id, type)}'?"} unless id 
          id
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
          when :scientific_taxon_id then v ? [:scientific_name, @session.taxonomy[v].name] : [:scientific_name, nil]
          when :common_taxon_id then v ? [:common_name, @session.taxonomy[v].name] : [:common_name, nil]
          else [k,v]
          end
        end.tap do |a|
          id = attributes[:scientific_taxon_id]
          a[:taxon_id] = @session.taxonomy[id].taxon_id if id 

          unless @in_collection
            sample_collections = sample_collections_metadata(attributes[:id])
            a[:sample_collections] = sample_collections if sample_collections
          end
        end
      end

      def in_collection!
        @in_collection = true
      end

      def reset_in_collection
        @in_collection = false
      end

      def sample_collections_metadata(sample_id)
        raise NotImplementedError, "sample_collection is not implemented"
      end
    end
  end
end
