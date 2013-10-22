require 'lims-core/persistence/persistor'
require 'lims-core/persistence/persist_association_trait'

module Lims::ManagementApp
  class SampleCollection

    (does "lims/core/persistence/persistable", :children => [
      {:name => :collection_sample, :session_name => :collection_sample, :deletable => true}
    ].tap { |children|
      SampleCollectionData::DATA_TYPES.each do |type|
        children << {:name => :"data_#{type}_proxy", :deletable => true}
      end
    }).class_eval do

      # @param [SampleCollection] sample_collection
      # @param [Array] children
      def children_collection_sample(sample_collection, children)
        sample_collection.samples.each do |sample|
          collection_sample = SampleCollectionPersistor::CollectionSample.new(sample_collection, sample)
          state = @session.state_for(collection_sample)
          state.resource = collection_sample
          children << collection_sample 
        end
      end

      # TODO : probably not the right place for that
      alias :filter_attributes_on_load_old :filter_attributes_on_load
      def filter_attributes_on_load(attributes)
        @session.sample.in_collection!
        filter_attributes_on_load_old(attributes)
      end

      # @param [SampleCollection] sample_collection
      # @param [Array] children
      # For each type defined in DATA_TYPES we create the corresponding children_ method.
      SampleCollectionData::DATA_TYPES.each do |type|
        self.class_eval <<-EOC
          def children_data_#{type}_proxy(sample_collection, children)
            sample_collection.data.select { |d| d.class::TYPE == "#{type}" }.each do |data|
              data_proxy = SampleCollectionPersistor::Data#{type.capitalize}Proxy.new(sample_collection, data)
              state = @session.state_for(data_proxy)
              state.resource = data_proxy
              children << data_proxy
            end
          end
        EOC
      end

      association_class "CollectionSample" do
        attribute :sample_collection, SampleCollection, :relation => :parent, :skip_parents_for_attributes => true
        attribute :sample, Sample, :relation => :parent

        def on_load
          if @sample_collection && @sample
            @sample_collection.samples << @sample
          end
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


      # For each type defined in DATA_TYPES, we create an association class
      # to link a sample collection to a data record.
      SampleCollectionData::DATA_TYPES.each do |type|
        self.class_eval do
          association_class "Data#{type.capitalize}Proxy" do
            attribute :sample_collection, SampleCollection, :relation => :parent, :skip_parents_for_attributes => true
            attribute :"data_#{type}", SampleCollectionData::const_get(:"Data#{type.capitalize}"), :relation => :parent, :deletable => true
          end
        end
      end

      SampleCollectionData::DATA_TYPES.each do |type|
        self.class_eval <<-EOC
          class self::Data#{type.capitalize}Proxy
            def attributes
              (@data_#{type} ? @data_#{type}.attributes : {}).merge(:sample_collection => @sample_collection)
            end

            def initialize(sample_collection, data)
              @sample_collection = sample_collection
              @data_#{type} = data
            end

            def on_load
              @sample_collection.data << @data_#{type}
            end

            def invalid?
              !@sample_collection.data.include?(@data_#{type})
            end

            class Data#{type.capitalize}ProxyPersistor
              def attribute_for(key)
                {sample_collection: 'sample_collection_id'}[key]
              end

              def new_from_attributes(attributes)
                collection = @session.sample_collection[attributes.delete(:sample_collection_id)]
                super(attributes) do |attr|
                  data = SampleCollectionData::Data#{type.capitalize}.new(attr)
                  model.new(collection, data).tap do |proxy|
                    proxy.on_load
                  end
                end
              end

              # ############
              # TODO: why ?
              # what's the semantic of deletable_parents/deletable_children?
              # ############
              def deletable_parents(resource)
                [resource]
              end

              def parents(resource)
                super(resource)
              end

              def parents_for_attributes(attr)
                []
              end
            end

            class Data#{type.capitalize}ProxySequelPersistor < self::Data#{type.capitalize}ProxyPersistor
              include Lims::Core::Persistence::Sequel::Persistor
              def self.table_name
                :collection_data_#{type}
              end
            end
          end
        EOC
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
