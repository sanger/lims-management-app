require 'lims-management-app/sample-collection/data/data_types'

module Lims::ManagementApp
  class SampleCollection
    module SampleCollectionData
      
      DATA_TYPES.each do |type|
        self.class_eval <<-EOC
          class #{type.capitalize}Persistor < Lims::Core::Persistence::Persistor
            Model = #{type.capitalize}
          end

          class #{type.capitalize}SequelPersistor < #{type.capitalize}Persistor
            def self.table_name
              :collection_data_#{type}
            end
          end
        EOC
      end
    end
  end
end
