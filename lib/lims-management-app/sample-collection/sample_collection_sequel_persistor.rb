require 'lims-management-app/sample-collection/sample_collection_persistor'
require 'lims-core/persistence/sequel/persistor'

module Lims::ManagementApp
  class SampleCollection
    class SampleCollectionSequelPersistor < SampleCollectionPersistor
      include Lims::Core::Persistence::Sequel::Persistor

      def self.table_name
        :collections
      end

      # @param [Integer] collection_id
      # @param [SampleCollection] collection
      def delete_children(collection_id, collection)
        @session.collection_sample.dataset.where(:collection_id => collection_id).delete
      end

      # @param [SampleCollection] collection
      # @param [Integer] collection_id
      # Delete first the data associated to the collection 
      # to verify the foreign key constraints.
      def delete_raw(collection, collection_id, *params)
        collection.data.each do |data|
          persistor = @session.persistor_for(data)
          persistor.dataset.where(persistor.primary_key => persistor.id_for(data)).delete
        end
        super
      end
    end

    
    class SampleCollectionMetadata
      class SampleCollectionMetadataSequelPersistor < SampleCollectionMetadataPersistor
        include Lims::Core::Persistence::Sequel::Persistor
        def self.table_name
          :collections
        end
      end
    end


    class CollectionSample
      class CollectionSampleSequelPersistor < CollectionSamplePersistor
        include Lims::Core::Persistence::Sequel::Persistor

        def self.table_name
          :collections_samples
        end

        # @param [Integer] collection_id
        # @param [Integer] sample_id
        def save_raw_association(collection_id, sample_id)
          dataset.insert(:collection_id => collection_id, :sample_id => sample_id)
        end

        # @param [Integer] collection_id
        # @param [Block] block
        def load_samples(collection_id, &block)
          @session.sample.in_collection!
          dataset.join(:samples, :id => :sample_id).where(:collection_id => collection_id).each do |attr|
            sample = @session.sample.get_or_create_single_model(attr[:sample_id], attr)
            block.call(sample)
          end
          @session.sample.reset_in_collection
        end
      end
    end
  end
end
