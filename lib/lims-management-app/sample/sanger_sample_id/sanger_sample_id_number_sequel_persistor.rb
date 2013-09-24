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
          lock(dataset, true) do |d|
            new_number = d.where(:id => 1).first[:number] + 1
            d.where(:id => 1).update(:number => new_number)
            new_number
          end
        end

        private

        # TODO: when using lims-core version 3, remove these methods and use
        # lock method from persistence/session.rb.
        def lock(datasets, unlock=false, &block)
          datasets = [datasets] unless datasets.is_a?(Array)
          db = datasets.first.db
          return lock_for_update(datasets, &block) if db.adapter_scheme =~ /sqlite/i

          db.run("LOCK TABLES #{datasets.map { |d| "#{d.first_source} WRITE"}.join(",")}")
          block.call(*datasets).tap { db.run("UNLOCK TABLES") if unlock }
        end

        def lock_for_update(datasets, &block)
          datasets.first.db.transaction do
            block.call(*datasets.map(&:for_update))
          end
        end
      end
    end
  end
end
