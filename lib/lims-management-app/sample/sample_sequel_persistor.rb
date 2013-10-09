require 'lims-management-app/sample/sample_persistor'
require 'lims-core/persistence/sequel/persistor'

module Lims::ManagementApp
  class Sample
    class SampleSequelPersistor < Sample::SamplePersistor
      include Lims::Core::Persistence::Sequel::Persistor

      def self.table_name
        :samples
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

      # @param [Integer] sample_id
      # @param [Block] block
      # About @in_collection:
      # Sample collections are loaded only when the sample is the resource the client asks for.
      # If the client asks for a collection, we do not want its samples load the collections 
      # they belongs to as well. Otherwise, might have an infinite loop of inclusion 
      # (collection load samples which load collections which load samples...)
      #
      # About in_sample!
      # Before loading a collection here, we set the @in_sample parameter which says 
      # the collection to not load the samples it contains. Here, we just want to load
      # the collection metadata.
      def load_sample_collections(sample_id, &block)
        unless @in_collection
          collection_id_rows = self.class.dataset(@session).from(:collections_samples).select(:collection_id).where(:sample_id => sample_id).all
          collection_ids = collection_id_rows.map { |r| r[:collection_id] }

          @session.sample_collection.in_sample!
          collection_ids.map { |id| @session.sample_collection[id] }.tap do |sample_collections|
            @session.sample_collection.reset_in_sample
            sample_collections.each { |collection| block.call(collection) } 
          end
        end
      end
    end
  end
end
