require 'lims-core/persistence/sequel/persistor'
require 'lims-management-app/sample/sample_persistor'

module Lims::ManagementApp
  class Sample
    class SampleSequelPersistor < SamplePersistor
      include Lims::Core::Persistence::Sequel::Persistor

      def filter_attributes_on_save(attributes)
        attributes.mash do |k,v|
          case k
          when :sanger_sample_id then [:sanger_sample_id, new_sanger_sample_id]
          else [k,v]
          end
        end
      end

      private

      def new_sanger_sample_id
        SangerSampleID.generate(unique_identifier)
      end

      def unique_identifier
        last_id = dataset.select(:id).limit(1).order(:id).last
        last_id ? last_id[:id] + 1 : 1
      end
    end
  end
end

