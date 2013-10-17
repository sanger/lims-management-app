require 'lims-core/persistence/persistor'
require 'lims-core/persistence/persist_association_trait'

module Lims::ManagementApp
  class SampleCollection
    (does "lims/core/persistence/persistable", :children => [
      {:name => :collection_sample, :session_name => :collection_sample, :deletable => true},
      {:name => :data_string_proxy, :deletable => true}
    ]).class_eval do
    #].tap do |children|
    #  DATA_TYPES.each do |type|
    #    children << {:name => :"data_#{type}_proxy", :deletable => true}
    #  end
    #end).class_eval do

      def children_collection_sample(sample_collection, children)
        sample_collection.samples.each do |sample|
          children << SampleCollectionPersistor::CollectionSample.new(sample_collection, sample)
        end
      end

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



      def children_data_string_proxy(collection, children)
        collection.data.select { |d| d.class::TYPE == "string" }.each do |data|
          data_string_proxy = SampleCollectionPersistor::DataStringProxy.new(collection, data)
          state = @session.state_for(data_string_proxy)
          state.resource = data_string_proxy
          children << data_string_proxy
        end
      end

      association_class "DataStringProxy" do
        attribute :sample_collection, SampleCollection, :relation => :parent, :skip_parents_for_attributes => true
        attribute :string, SampleCollectionData::String, :relation => :parent, :deletable => true
      end

      class self::DataStringProxy
        def attributes
          (@string ? @string.attributes : {}).merge(:sample_collection => @sample_collection)
        end

        def initialize(sample_collection, data_string)
          @sample_collection = sample_collection
          @string = data_string
        end

        def on_load
          @sample_collection.data << @string
        end

        def invalid?
          !@sample_collection.data.include?(@string)
        end

        class DataStringProxyPersistor
          def attribute_for(key)
            {sample_collection: 'sample_collection_id'}[key]
          end

          def new_from_attributes(attributes)
            collection = @session.sample_collection[attributes.delete(:sample_collection_id)]
            super(attributes) do |attr|
              data_string = SampleCollectionData::String.new(attr)
              model.new(collection, data_string).tap do |proxy|
                proxy.on_load
              end
            end
          end

          def parents(resource)
            super(resource)
          end

          def parents_for_attributes(attr)
            []
          end
        end
      end

      class self::DataStringProxy
        class DataStringProxySequelPersistor < self::DataStringProxyPersistor
          include Lims::Core::Persistence::Sequel::Persistor
          def self.table_name
            :collection_data_string
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
