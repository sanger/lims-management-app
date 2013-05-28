require 'lims-core/persistence/sequel/persistor'
require 'lims-management-app/sample/genotyping/genotyping_persistor'

module Lims::ManagementApp
  class Sample
    class Genotyping
      class GenotypingSequelPersistor < GenotypingPersistor
        include Lims::Core::Persistence::Sequel::Persistor

        def self.table_name
          :genotyping
        end
      end
    end
  end
end
