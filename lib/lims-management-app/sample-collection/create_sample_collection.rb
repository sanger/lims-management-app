require 'lims-core/actions/action'
require 'lims-management-app/sample-collection/sample_collection'

module Lims::ManagementApp
  class SampleCollection
    class CreateSampleCollection
      include Lims::Core::Actions::Action
      include ValidationShared

      SampleNotFound = Class.new(StandardError)

      attribute :type, String, :required => true
      attribute :data, Array, :required => false, :default => []
      attribute :sample_uuids, Array, :required => false, :default => []

      def _call_in_session(session)
        collection = SampleCollection.new(:type => type, :data => prepared_data, :samples => prepared_samples(session))
        session << collection
        {:sample_collection => collection, :uuid => session.uuid_for!(collection)}
      end

      def prepared_data
        data.map do |d|
          SampleCollectionData.const_get(d["type"].capitalize).new({
            :key => d["key"],
            :value => d["value"]
          })
        end
      end

      def prepared_samples(session)
        sample_uuids.map do |uuid|
          sample = session[uuid]
          raise SampleNotFound, "The sample '#{uuid}' cannot be found" unless sample
          sample
        end
      end

    end

    Create = CreateSampleCollection
  end
end
