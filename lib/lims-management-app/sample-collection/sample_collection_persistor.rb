require 'lims-core/persistence/persistor'
require 'lims-management-app/sample-collection/data/data_types_persistor'

module Lims::ManagementApp
  class SampleCollection
    class SampleCollectionPersistor < Lims::Core::Persistence::Persistor
      Model = SampleCollection

      # @param [Integer] collection_id
      # @param [SampleCollection] collection
      def save_children(collection_id, collection)
        collection.samples.each do |sample|
          collection_sample.save_as_association(collection_id, sample) 
        end

        collection.data.each do |data|
          @session.save(data, collection_id)
        end
      end

      # @param [Integer] collection_id
      # @param [SampleCollection] collection
      def load_children(collection_id, collection)
        collection_sample.load_samples(collection_id) do |sample|
          collection.samples << sample
        end
      end

      # @param [Hash] attributes
      # @return [Hash]
      def filter_attributes_on_save(attributes)
        attributes.delete(:samples)
        attributes.delete(:data)
        attributes
      end

      # @return [CollectionSamplePersistor]
      def collection_sample
        @session.collection_sample
      end
    end

    class CollectionSample
      SESSION_NAME = :collection_sample
      class CollectionSamplePersistor < Lims::Core::Persistence::Persistor
      end
    end
  end
end
