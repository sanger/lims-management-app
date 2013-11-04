require 'lims-management-app/sample-collection/data/helper'

module Lims::ManagementApp
  class SampleCollection

    SampleNotFound = Class.new(StandardError)

    module ActionShared
      # Map the data hash to SampleCollectionData objects
      def prepared_data
        data.map do |d|
          key, value = d["key"], d["value"]
          type = d["type"] || SampleCollectionData::Helper.discover_type_of(value)
          SampleCollectionData.const_get(:"Data#{type.capitalize}").new(:key => key, :value => value)
        end
      end

      # Map the sample uuids to the sample objects
      def prepared_samples(session)
        sample_uuids.map do |uuid|
          sample = session[uuid]
          raise SampleCollection::SampleNotFound, "The sample '#{uuid}' cannot be found" unless sample
          sample
        end
      end
    end
  end
end
