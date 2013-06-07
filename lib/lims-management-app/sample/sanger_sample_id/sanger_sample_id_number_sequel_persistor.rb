require 'lims-core/persistence/sequel/persistor'
require 'lims-management-app/sample/sanger_sample_id/sanger_sample_id_number_persistor'

module Lims::ManagementApp
  class Sample
    class SangerSampleIdNumber
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
