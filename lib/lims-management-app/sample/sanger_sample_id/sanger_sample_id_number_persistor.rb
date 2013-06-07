require 'lims-core/persistence/persistor'

module Lims::ManagementApp
  class Sample
    class SangerSampleIdNumber
      class SangerSampleIdNumberPersistor < Lims::Core::Persistence::Persistor
        Model = Sample::SangerSampleIdNumber
      end
    end
  end
end
