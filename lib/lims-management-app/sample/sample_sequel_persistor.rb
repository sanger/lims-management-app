require 'lims-management-app/sample/sample_persistor'
require 'lims-core/persistence/sequel/persistor'

module Lims::ManagementApp
  class Sample
    class SampleSequelPersistor < Sample::SamplePersistor
      include Lims::Core::Persistence::Sequel::Persistor

      def self.table_name
        :samples
      end

      private

      # @param [Object] object
      # @param [Integer] id
      # @param [Arguments] params
      # @return [Integer]
      # Override lims-core sequel/persistor#delete_raw.
      # After a sample is deleted, we need to delete
      # the DNA, RNA, Cellular Material it references 
      # with its foreign keys. We need to first delete
      # the sample object to verify the constraints.
      def delete_raw(object, id, *params)
        sample_id = super
        components = [object.dna, object.rna, object.cellular_material, object.genotyping]
        components.each do |component|
          if component
            persistor = @session.persistor_for(component)
            persistor_dataset = persistor.dataset
            persistor_dataset.filter(persistor.primary_key => persistor.id_for(component)).delete
          end
        end
        sample_id
      end
    end
  end
end
