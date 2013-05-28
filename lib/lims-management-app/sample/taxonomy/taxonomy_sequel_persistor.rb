require 'lims-core/persistence/sequel/persistor'
require 'lims-management-app/sample/taxonomy/taxonomy_persistor'

module Lims::ManagementApp
  class Sample
    class Taxonomy
      class TaxonomySequelPersistor < TaxonomyPersistor
        include Lims::Core::Persistence::Sequel::Persistor

        def self.table_name
          :taxonomies
        end

        # @param [Integer] taxon_id
        # @param [String] type
        # @return [Boolean]
        # Return true if the couple (taxon_id, type) has been 
        # found in the taxonomies table.
        def valid_taxon_id?(taxon_id, type)
          self.dataset.where(:taxon_id => taxon_id).where {
            { lower(:type) => lower(type) }
          }.where(:deleted => nil).count > 0
        end

        # @param [Integer] taxon_id
        # @param [String] type
        # @return [String]
        # Return either the scientific name or the common name
        # associated to the taxon_id.
        def name_by_taxon_id(taxon_id, type)
          self.dataset.select(:name).where(:taxon_id => taxon_id).where {
            { lower(:type) => lower(type) }
          }.where(:deleted => nil).first[:name]
        end

        # @param [Integer] taxon_id
        # @param [String] name
        # @param [String] type
        # @return [Integer,Nil]
        # Case insensitive lookup for the taxonomy id
        # based on taxon_id, name and type.
        def id_by_taxon_id_and_name(taxon_id, name, type)
          record = self.dataset.select(primary_key).where({
            :taxon_id => taxon_id
          }).where {
            {lower(:name) => lower(name)}
          }.where {
            {lower(:type) => lower(type)}
          }.where(:deleted => nil).first
          record ? record[primary_key] : nil
        end
      end
    end
  end
end
