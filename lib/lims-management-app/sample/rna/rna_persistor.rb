require 'lims-core/persistence/persistor'

module Lims::ManagementApp
  class Sample
    class Rna
      class RnaPersistor < Lims::Core::Persistence::Persistor
        Model = Sample::Rna
      end
    end
  end
end
