require 'lims-core/persistence/persistor'

module Lims::ManagementApp
  class Sample
    class CellularMaterial
      class CellularMaterialPersistor < Lims::Core::Persistence::Persistor
        Model = Sample::CellularMaterial

        def filter_attributes_on_save(attributes)
          attributes.reject { |k,v| k == :extraction_process }
        end

      end
    end
  end
end
