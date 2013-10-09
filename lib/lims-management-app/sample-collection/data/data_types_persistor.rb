require 'lims-management-app/sample-collection/data/data_types'
require 'lims-core/persistence/sequel/persistor'

module Lims::ManagementApp
  class SampleCollection
    # Define persistor and sequel persistor classes for each
    # types defined in DATA_TYPES.
    module SampleCollectionData

      DATA_TYPES.each do |type|
        base_name = type.capitalize
        self.class_eval <<-EOC
          class #{base_name}
            SESSION_NAME = :collection_data_#{type}
            class #{base_name}Persistor < Lims::Core::Persistence::Persistor
              Model = #{base_name}

              def filter_attributes_on_save(attributes, collection_id=nil)
                attributes[:collection_id] = collection_id if collection_id
                attributes
              end

              def filter_attributes_on_load(attributes, collection_id=nil)
                attributes
              end

              def load_data(collection_id)
                dataset.where(:collection_id => collection_id).all
              end
            end

            class #{base_name}SequelPersistor < #{base_name}Persistor
              include Lims::Core::Persistence::Sequel::Persistor
              def self.table_name
                :collection_data_#{type}
              end
            end
          end
        EOC
      end
    end
  end
end
