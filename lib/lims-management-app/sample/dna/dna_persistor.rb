require 'lims-core/persistence/persistor'

module Lims::ManagementApp
  class Sample
    class Dna
      class DnaPersistor < Lims::Core::Persistence::Persistor
        Model = Sample::Dna
      end
    end
  end
end
