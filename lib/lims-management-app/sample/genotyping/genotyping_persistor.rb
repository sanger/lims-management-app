require 'lims-core/persistence/persistor'

module Lims::ManagementApp
  class Sample
    class Genotyping
      class GenotypingPersistor < Lims::Core::Persistence::Persistor
        Model = Sample::Genotyping
      end
    end
  end
end
