module Lims::ManagementApp
  class SampleCollection
    module ValidationShared

      COLLECTION_TYPES = ["Manifest", "Accessing", "Study", "User"]
      DATA_TYPE_STRING = "string"
      DATA_TYPE_INT = "integer"
      DATA_TYPE_URL = "url"
      DATA_TYPE_UUID = "uuid"
      DATA_TYPES = [DATA_TYPE_STRING, DATA_TYPE_INT, DATA_TYPE_URL, DATA_TYPE_UUID]

      VALID_URL_PATTERN = /^http:\/\/.*$/i
      VALID_UUID_PATTERN = /#{[8,4,4,4,12].map { |n| "[0-9a-f]{#{n}}" }.join("-")}/i

      def self.included(klass)
        klass.class_eval do
          validates_with_method :ensure_type_parameter
          validates_with_method :ensure_data_parameter
        end
      end

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
        if data
          data.each do |d|
            unless d.is_a?(Hash) && d.keys.sort == ["key", "type", "value"]
              return [false, "Error found in data: '#{d.inspect}'. It must be a triple (key, type, value)"]
            end

            key, type, value = d["key"], d["type"], d["value"]
            unless DATA_TYPES.include?(type.downcase)
              return [false, "Type must belong to the valid types #{DATA_TYPES.inspect}: '#{type}'"]
            end

            return ensure_data_type_value_matching(type, value)
          end
        end
      end

      def ensure_data_type_value_matching(type, value)
        error = false
        case type
        when DATA_TYPE_STRING then error = true unless value.is_a?(String)
        when DATA_TYPE_INT then error = true unless value.is_a?(Integer)
        when DATA_TYPE_URL then error = true unless value =~ VALID_URL_PATTERN
        when DATA_TYPE_UUID then error = true unless value =~ VALID_UUID_PATTERN
        end
        error ? [false, "Type/value mismatch: '#{value}' is not a '#{type}'"] : [true]
      end
    end
  end
end
