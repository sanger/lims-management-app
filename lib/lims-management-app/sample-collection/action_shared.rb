module Lims::ManagementApp
  class SampleCollection

    SampleNotFound = Class.new(StandardError)

    module ActionShared
      # Map the data hash to SampleCollectionData objects
      def prepared_data
        data.map do |d|
          SampleCollectionData.const_get(d["type"].capitalize).new({
            :key => d["key"],
            :value => d["value"]
          })
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
