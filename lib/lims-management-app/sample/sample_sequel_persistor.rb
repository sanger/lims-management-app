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

      # @return [String]
      # Generate a new sanger sample id
      def new_sanger_sample_id
        SangerSampleID.generate
      end
    end
  end
end

