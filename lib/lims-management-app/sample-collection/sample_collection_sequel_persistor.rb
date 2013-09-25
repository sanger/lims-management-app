require 'lims-management-app/sample-collection/sample_collection_persistor'
require 'lims-core/persistence/sequel/persistor'

module Lims::ManagementApp
  class SampleCollection
    class SampleCollectionSequelPersistor < SampleCollectionPersistor
      include Lims::Core::Persistence::Sequel::Persistor

      def self.table_name
        :collections
      end
    end

    class CollectionSample
      class CollectionSampleSequelPersistor < CollectionSamplePersistor
        include Lims::Core::Persistence::Sequel::Persistor

        def self.table_name
          :collections_samples
        end

        def save_raw_association(collection_id, sample_id)
          dataset.insert(:collection_id => collection_id, :sample_id => sample_id)
        end

        def load_samples(collection_id, &block)
          dataset.join(:samples, :id => :sample_id).where(:collection_id => collection_id).each do |attr|
            sample = @session.sample.get_or_create_single_model(attr[:sample_id], attr)
            block.call(sample)
          end
        end
      end
    end
  end
end
