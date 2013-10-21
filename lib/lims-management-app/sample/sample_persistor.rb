require 'lims-core/persistence/persistable_trait'
require 'lims-core/persistence/persist_association_trait'
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
        attributes = attributes.reject { |k,v| k == :taxon_id || k == :sample_collections }.mash do |k,v|
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

      # @param [Lims::Core::Persistence::StateGroup] states
      # Sample collections are defined as sample's children.
      def load_children(states)
        if @in_collection
          super(states)
        else
          load_sample_collections(states.map(&:id)) do |sample_ids, collection|
            sample_ids.each do |sample_id|
              sample = @session.sample[sample_id]
              unless sample.sample_collections.include?(collection)
                @session.sample[sample_id].sample_collections << collection
              end
            end
          end
        end
      end

      # @param [Array] sample_ids
      # @param [Block] block
      def load_sample_collections(sample_ids, &block)
        collection_id_rows = self.class.dataset(@session).from(:collections_samples).select(:sample_collection_id).where(:sample_id => sample_ids).all
        collection_ids = collection_id_rows.map { |r| r[:sample_collection_id] }

        collection_ids.map { |id| @session.sample_collection[id] }.tap do |sample_collections|
          sample_collections.each { |collection| block.call(sample_ids, collection) } 
        end
      end

      def in_collection!
        @in_collection = true
      end

      def sample_collection
        @session.sample_collection
      end
    end
  end
end
