require 'lims-management-app/sample-collection/data/data_types'

module Lims::ManagementApp
  class SampleCollection
    module SampleCollectionData
      module Helper
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
      end
    end
  end
end
