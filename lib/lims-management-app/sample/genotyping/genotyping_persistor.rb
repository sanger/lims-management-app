require 'lims-core/persistence/persistable_trait'
require 'lims-core/persistence/sequel/persistor'

module Lims::ManagementApp
  class Sample
    class Genotyping
      does "lims/core/persistence/persistable" 

      class GenotypingSequelPersistor < GenotypingPersistor
        include Lims::Core::Persistence::Sequel::Persistor
        def self.table_name
          :genotyping
        end
      end
    end
  end
end
