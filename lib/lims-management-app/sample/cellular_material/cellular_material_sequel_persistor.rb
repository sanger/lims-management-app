require 'lims-core/persistence/sequel/persistor'
require 'lims-management-app/sample/cellular_material/cellular_material_persistor'

module Lims::ManagementApp
  class Sample
    class CellularMaterial
      class CellularMaterialSequelPersistor < CellularMaterialPersistor
        include Lims::Core::Persistence::Sequel::Persistor

        def self.table_name
          :cellular_material
        end
      end
    end
  end
end
