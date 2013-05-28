require 'lims-core/persistence/persistor'

module Lims::ManagementApp
  class Sample
    class CellularMaterial
      class CellularMaterialPersistor < Lims::Core::Persistence::Persistor
        Model = Sample::CellularMaterial
      end
    end
  end
end
