module Lims::ManagementApp
  class SampleCollection

    SampleNotFound = Class.new(StandardError)

    module ActionShared
      # Map the data hash to SampleCollectionData objects
      def prepared_data
        data.map do |d|
          key, value = d["key"], d["value"]
          type = d["type"] || self.class.discover_type_of(value)
          SampleCollectionData.const_get(type.capitalize).new(:key => key, :value => value)
        end
      end

      # @param [String] value
      # @return [String]
      def self.discover_type_of(value)
        case value
        when Integer then SampleCollectionData::DATA_TYPE_INT 
        when TrueClass then SampleCollectionData::DATA_TYPE_BOOL
        when FalseClass then SampleCollectionData::DATA_TYPE_BOOL 
        when ValidationShared::VALID_URL_PATTERN then SampleCollectionData::DATA_TYPE_URL 
        when ValidationShared::VALID_UUID_PATTERN then SampleCollectionData::DATA_TYPE_UUID 
        else SampleCollectionData::DATA_TYPE_STRING
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
