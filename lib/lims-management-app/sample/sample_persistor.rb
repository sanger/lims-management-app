require 'lims-core/persistence/persistor'
require 'lims-management-app/sample/sample'

module Lims::ManagementApp
  class Sample
    class SamplePersistor < Lims::Core::Persistence::Persistor
      Model = Sample
    end
  end
end

