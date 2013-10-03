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
      DataTypeMismatch = Class.new(StandardError)

      attribute :sample_collection, SampleCollection, :required => true
      attribute :data, Array, :required => false, :default => []
      attribute :sample_uuids, Array, :required => false, :default => []
      validates_with_method :ensure_data_parameter

      def _call_in_session(session)
        update_data
        update_samples(session)
        {:sample_collection => sample_collection}
      end

      def update_data
        # We update the data which are overriden by the new data parameters
        data.inject({}) { |m,e| m.merge(e["key"] => {:value => e["value"], :type => e["type"]}) }.tap do |data_h|
          sample_collection.data.each do |collection_data|
            if data_h.keys.include?(collection_data.key)
              current_data = data_h[collection_data.key]
              value = current_data[:value]
              type = current_data[:type] || SampleCollectionData::Helper.discover_type_of(value)
              raise DataTypeMismatch unless type == collection_data.class::TYPE

              collection_data.value = value 
              data.delete_if { |d| d["key"] == collection_data.key }
            end
          end
        end

        # We add the new data to the collection
        sample_collection.add_data(prepared_data)
      end

      def update_samples(session)
        # We delete all the samples which do not appear 
        # in the sample_uuids parameter from the collection
        collection_sample_uuids = []
        sample_collection.samples.keep_if do |sample|
          collection_sample_uuid = session.uuid_for(sample)
          collection_sample_uuids << collection_sample_uuid
          sample_uuids.include?(collection_sample_uuid)
        end

        # We delete the uuids of the samples which are already
        # in the collection
        sample_uuids.delete_if do |uuid|
          collection_sample_uuids.include?(uuid)
        end

        sample_collection.add_samples(prepared_samples(session))
      end
    end

    Update = UpdateSampleCollection
  end
end
