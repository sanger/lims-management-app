require 'lims-core/persistence/persistable_trait'
require 'lims-core/persistence/sequel/persistor'
require 'lims-core/actions/action'

module Lims::ManagementApp
  class Sample
    UnknownTaxonIdError = Class.new(Lims::Core::Actions::Action::InvalidParameters)
    NameTaxonIdMismatchError = Class.new(Lims::Core::Actions::Action::InvalidParameters)

    does "lims/core/persistence/persistable", :parents => [
      {:name => :dna, :deletable => true},
      {:name => :rna, :deletable => true},
      {:name => :cellular_material, :deletable => true},
      {:name => :genotyping, :deletable => true}
    ]

    class SampleSequelPersistor < SamplePersistor
      include Lims::Core::Persistence::Sequel::Persistor

      def self.table_name
        :samples
      end

      def attribute_for(key)
        {
          :dna => 'dna_id',
          :rna => 'rna_id',
          :cellular_material => 'cellular_material_id',
          :genotyping => 'genotyping_id'
        }[key]
      end

      alias filter_attributes_on_save_old filter_attributes_on_save
      def filter_attributes_on_save(attributes)
        taxon_id = attributes[:taxon_id]
        attributes = attributes.reject { |k,v| k == :taxon_id }.mash do |k,v|
          case k
          when :scientific_name then [:scientific_taxon_id, taxonomy_primary_id(taxon_id, v, "scientific name")]
          when :common_name then [:common_taxon_id, taxonomy_primary_id(taxon_id, v, "common name")]
          else [k,v]
          end
        end
        filter_attributes_on_save_old(attributes)
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
        end
      end

      private

      # @param [Object] object
      # @param [Integer] id
      # @param [Arguments] params
      # @return [Integer]
      # Override lims-core sequel/persistor#delete_raw.
      # After a sample is deleted, we need to delete
      # the DNA, RNA, Cellular Material it references 
      # with its foreign keys. We need to first delete
      # the sample object to verify the constraints.
      def delete_raw(object, id, *params)
        sample_id = super
        components = [object.dna, object.rna, object.cellular_material, object.genotyping]
        components.each do |component|
          if component
            persistor = @session.persistor_for(component)
            persistor_dataset = persistor.dataset
            persistor_dataset.filter(persistor.primary_key => persistor.id_for(component)).delete
          end
        end
        sample_id
      end
    end
  end
end
