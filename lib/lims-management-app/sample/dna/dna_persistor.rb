require 'lims-core/persistence/persistable_trait'
require 'lims-core/persistence/sequel/persistor'

module Lims::ManagementApp
  class Sample
    class Dna
      does "lims/core/persistence/persistable"

      class DnaSequelPersistor < DnaPersistor
        include Lims::Core::Persistence::Sequel::Persistor
        def self.table_name
          :dna
        end
      end
    end
  end
end
