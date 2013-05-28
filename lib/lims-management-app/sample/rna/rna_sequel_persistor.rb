require 'lims-core/persistence/sequel/persistor'
require 'lims-management-app/sample/rna/rna_persistor'

module Lims::ManagementApp
  class Sample
    class Rna
      class RnaSequelPersistor < RnaPersistor
        include Lims::Core::Persistence::Sequel::Persistor

        def self.table_name
          :rna
        end
      end
    end
  end
end
