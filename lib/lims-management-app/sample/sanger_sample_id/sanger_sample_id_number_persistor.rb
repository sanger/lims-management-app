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
          @sanger_sample_id_numbers.shift
        end

        # @param [Integer] quantity
        # In multithreading environment, we need to lock the table
        # sanger_sample_id_number to avoid race conditions problem.
        def prefetch_sanger_sample_id_number(quantity = 1)
          @session.lock(dataset, true) do |d|
            current_number = d.where(:id => 1).first[:number]
            new_number = current_number + quantity
            d.where(:id => 1).update(:number => new_number)
            @sanger_sample_id_numbers = (current_number+1..new_number).to_a
          end
        end
      end
    end
  end
end
