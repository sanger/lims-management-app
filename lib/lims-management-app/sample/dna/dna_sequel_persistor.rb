require 'lims-core/persistence/sequel/persistor'
require 'lims-management-app/sample/dna/dna_persistor'

module Lims::ManagementApp
  class Sample
    class Dna
      class DnaSequelPersistor < DnaPersistor
        include Lims::Core::Persistence::Sequel::Persistor

        def self.table_name
          :dna
        end
      end
    end
  end
end
