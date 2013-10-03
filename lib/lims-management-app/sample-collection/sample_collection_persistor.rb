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
        unless @in_sample
          collection_sample.load_samples(collection_id) do |sample|
            collection.samples << sample
          end
        end

        load_data(collection_id) do |data|
          collection.data << data
        end
      end

      def in_sample!
        @in_sample = true
      end

      def reset_in_sample
        @in_sample = false
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

      # @param [Integer] collection_id
      # @param [Block] block
      def load_data(collection_id, &block)
        SampleCollectionData::DATA_TYPES.map do |type|
          @session.send("collection_data_#{type}")
        end.each do |data_persistor|
          data_persistor.load_data(collection_id).each do |data|
            block.call(data_persistor.get_or_create_single_model(data[:id], data))
          end
        end
      end

      SampleCollectionData::DATA_TYPES.each do |type|
        define_method("collection_data_#{type}") do
          @session.send("collection_data_#{type}")
        end
      end
    end


    class CollectionSample
      SESSION_NAME = :collection_sample
      class CollectionSamplePersistor < Lims::Core::Persistence::Persistor
        def load_samples(collection_id, &block)
          raise NotImplementedError, "load_samples is not implemented"
        end
      end
    end
  end
end
