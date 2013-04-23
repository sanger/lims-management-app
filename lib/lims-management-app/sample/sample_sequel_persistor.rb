require 'lims-core/persistence/sequel/persistor'
require 'lims-management-app/sample/sample_persistor'

module Lims::ManagementApp
  class Sample
    class SampleSequelPersistor < SamplePersistor
      include Lims::Core::Persistence::Sequel::Persistor

    end
  end
end

