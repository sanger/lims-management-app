require 'lims-core/persistence/persistable_trait'
require 'lims-core/persistence/sequel/persistor'

module Lims::ManagementApp
  class Sample
    class Rna
      does "lims/core/persistence/persistable" 

      class RnaSequelPersistor < RnaPersistor
        include Lims::Core::Persistence::Sequel::Persistor
        def self.table_name
          :rna
        end
      end
    end
  end
end
