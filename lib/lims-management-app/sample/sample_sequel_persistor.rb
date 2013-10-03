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

      def sample_collections_metadata(sample_id)
        collection_id_rows = self.class.dataset(@session).from(:collections_samples).select(:collection_id).where(:sample_id => sample_id).all
        collection_ids = collection_id_rows.map { |r| r[:collection_id] }
        @session.sample_collection.in_sample!
        collection_ids.map { |id| @session.sample_collection[id] }.tap do |_|
          @session.sample_collection.reset_in_sample
        end
      end
    end
  end
end
