require 'lims-core/persistence/persistor'
require 'lims-core/persistence/persist_association_trait'
#require 'lims-management-app/sample-collection/data/data_types_persistor'
require 'lims-laboratory-app/container_persistor_trait'

module Lims::ManagementApp
  class SampleCollection
    (does "lims/core/persistence/persistable", :children => [
      {:name => :collection_sample, :session_name => :collection_sample, :deletable => true}
      #{:name => :collection_data_string, :deletable => true}
    ]).class_eval do

      def children_collection_sample(sample_collection, children)
        sample_collection.samples.each do |sample|
          children << SampleCollectionPersistor::CollectionSample.new(sample_collection, sample)
        end
      end

#      def children_data_string(collection, children)
#        collection.data.select { |d| d.class::TYPE == "string" }.each do |data|
#          children << data
#        end
#      end


      association_class "CollectionSample" do
        attribute :sample_collection, SampleCollection, :relation => :parent, :skip_parents_for_attributes => true
        attribute :sample, Sample, :relation => :parent

        def on_load
          @sample_collection.samples << @sample if @sample_collection && @sample
        end

        def invalid?
          @sample && !@sample_collection.samples.include?(@sample)
        end
      end

      class self::CollectionSample
        class CollectionSampleSequelPersistor < self::CollectionSamplePersistor
          include Lims::Core::Persistence::Sequel::Persistor
          def self.table_name
            :collections_samples
          end
        end
      end
    end


    class SampleCollectionSequelPersistor < SampleCollectionPersistor
      include Lims::Core::Persistence::Sequel::Persistor
      def self.table_name
        :collections
      end
    end
  end
end

  ###################
  # Collection data #
  ###################
  #
  #    does "lims/laboratory_app/container_persistor", :element => :data_string_proxy, 
  #      :table_name => :collection_data_string, :contained_class => SampleCollectionData::String
  #
  #    class SampleCollectionPersistor
  #      def children_data_string_proxy(collection, children)
  #        collection.data.select { |d| d.class::TYPE == "string" }.each do |data|
  #          data_string_proxy = DataStringProxy.new(collection, nil, data)
  #          state = @session.state_for(data_string_proxy)
  #          state.resource = data_string_proxy
  #          children << data_string_proxy
  #        end
  #      end
  #    
  #      class DataStringProxy
  #        def attributes
  #          @string ? @string.attributes.merge(:sample_collection => @sample_collection) : {}
  #        end
  #
  #        def invalid?
  #          !@sample_collection.data.include?(@string)
  #        end
  #
  #        def on_load
  #          @sample_collection.data << @string
  #        end
  #
  #        class DataStringProxyPersistor
  #          def attribute_for(key)
  #            {sample_collection: 'sample_collection_id'}[key]
  #          end
  #
  #          def self.table_name
  #            :collection_data_string
  #          end
  #
  #          def new_from_attributes(attributes)
  #            collection = @session.sample_collection[attributes.delete(:sample_collection_id)]
  #            super(attributes) do |attr|
  #              data_string = SampleCollectionData::String.new(attr)
  #              model.new(collection, nil, data_string).tap do |proxy|
  #                proxy.on_load
  #              end
  #            end
  #          end
  #
  #          def parents(resource)
  #            super(resource)
  #          end
  #
  #          def parents_for_attributes(attr)
  #            []
  #          end
  #        end
  #      end
  #    end


