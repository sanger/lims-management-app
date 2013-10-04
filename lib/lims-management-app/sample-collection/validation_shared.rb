require 'lims-management-app/sample-collection/data/helper'
require 'lims-management-app/sample-collection/data/data_types'

module Lims::ManagementApp
  class SampleCollection
    module ValidationShared

      COLLECTION_TYPES = ["Manifest", "Accessing", "Study", "User"]
      VALID_URL_PATTERN = /^http:\/\/.*$/i
      VALID_UUID_PATTERN = /#{[8,4,4,4,12].map { |n| "[0-9a-f]{#{n}}" }.join("-")}/i

      def ensure_type_parameter
        if type
          if COLLECTION_TYPES.map(&:downcase).include?(type.downcase) 
            [true]
          else
            [false, "'#{type}' is not a valid collection type"]
          end
        end
      end

      def ensure_data_parameter
        keys = []
        data.each do |d|
          unless d.is_a?(Hash) && (d.keys & ["key","value"]).sort == ["key", "value"]
            return [false, "Data must be a hash containing the element 'key' and 'value'"]
          end

          key, value = d["key"], d["value"]
          keys << key
          type = d["type"] || SampleCollectionData::Helper.discover_type_of(value)
          unless type.nil? || SampleCollectionData::DATA_TYPES.include?(type)
            return [false, "'#{type}' is not a valid type. Supported types are #{SampleCollectionData::DATA_TYPES.inspect}"]
          end

          check_type_value = ensure_data_parameter_value(type, value)
          return check_type_value unless check_type_value.first
        end

        check_key_uniqueness = ensure_data_parameter_key_uniqueness(keys)
        return check_key_uniqueness unless check_key_uniqueness.first

        [true]
      end

      def ensure_data_parameter_key_uniqueness(keys)
        unless keys.size == keys.uniq.size
          [false, "Duplicate keys have been found"]
        else 
          [true]
        end
      end

      def ensure_data_parameter_value(type, value)
        error = false
        case type
        when SampleCollectionData::DATA_TYPE_STRING then error = true unless value.is_a?(String)
        when SampleCollectionData::DATA_TYPE_INT then error = true unless value.is_a?(Integer)
        when SampleCollectionData::DATA_TYPE_URL then error = true unless value =~ VALID_URL_PATTERN
        when SampleCollectionData::DATA_TYPE_UUID then error = true unless value =~ VALID_UUID_PATTERN
        when SampleCollectionData::DATA_TYPE_BOOL then error = true unless value.is_a?(TrueClass) || value.is_a?(FalseClass)
        else return [false, "Error found in data: '#{type}' isn't a valid sample collection data type"]
        end
        error ? [false, "Type/value mismatch: '#{value}' is not a valid value for '#{type}'"] : [true]     
      end
    end
  end
end
