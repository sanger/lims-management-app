require 'lims-core/persistence/persistable_trait'
require 'lims-core/persistence/sequel/persistor'

module Lims::ManagementApp
  class Sample
    class SangerSampleIdNumber
      does "lims/core/persistence/persistable" 

      class SangerSampleIdNumberSequelPersistor < SangerSampleIdNumberPersistor 
        include Lims::Core::Persistence::Sequel::Persistor

        def self.table_name
          :sanger_sample_id_number
        end

        def generate_new_number
          new_number = self.dataset.where(:id => 1).first[:number] + 1
          self.dataset.where(:id => 1).update(:number => new_number)
          new_number
        end
      end
    end
  end
end
