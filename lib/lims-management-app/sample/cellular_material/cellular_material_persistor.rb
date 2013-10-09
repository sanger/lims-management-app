require 'lims-core/persistence/persistable_trait'
require 'lims-core/persistence/sequel/persistor'

module Lims::ManagementApp
  class Sample
    class CellularMaterial
      does "lims/core/persistence/persistable" 

      class CellularMaterialPersistor
        def filter_attributes_on_save(attributes)
          attributes.reject { |k,v| k == :extraction_process }
        end
      end

      class CellularMaterialSequelPersistor < CellularMaterialPersistor
        include Lims::Core::Persistence::Sequel::Persistor
        def self.table_name
          :cellular_material
        end
      end
    end
  end
end
