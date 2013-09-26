require 'lims-core/actions/action'
require 'lims-management-app/sample-collection/sample_collection'
require 'lims-management-app/sample-collection/action_shared'

module Lims::ManagementApp
  class SampleCollection
    class UpdateSampleCollection
      include Lims::Core::Actions::Action
      include ValidationShared
      include ActionShared

      SampleNotFound = Class.new(StandardError)

      attribute :collection, SampleCollection, :required => true
      attribute :data, Array, :required => false, :default => []
      attribute :sample_uuids, Array, :required => false, :default => []
      validates_with_method :ensure_data_parameter

      def _call_in_session(session)
        update_data
        update_samples(session)
        {:sample_collection => collection}
      end

      def update_data
        # We delete the data which are overriden by the new data parameters
        data.inject([]) { |m,e| m << e["key"] }.tap do |keys|
          collection.data.delete_if do |element|
            keys.include?(element.key)
          end
        end

        # We add the new data to the collection
        collection.data |= prepared_data
      end

      def update_samples(session)
        # We delete all the samples which do not appear 
        # in the sample_uuids parameter from the collection
        collection_sample_uuids = []
        collection.samples.keep_if do |sample|
          collection_sample_uuid = session.uuid_for(sample)
          collection_sample_uuids << collection_sample_uuid
          sample_uuids.include?(collection_sample_uuid)
        end

        # We delete the uuids of the samples which are already
        # in the collection
        sample_uuids.delete_if do |uuid|
          collection_sample_uuids.include?(uuid)
        end

        collection.samples |= prepared_samples(session)
      end
    end

    Update = UpdateSampleCollection
  end
end
