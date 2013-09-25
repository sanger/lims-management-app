module Lims::ManagementApp
  class SampleCollection
    module ValidationShared

      COLLECTION_TYPES = ["Manifest", "Accessing", "Study", "User"]
      VALID_URL_PATTERN = /^http:\/\/.*$/i
      VALID_UUID_PATTERN = /#{[8,4,4,4,12].map { |n| "[0-9a-f]{#{n}}" }.join("-")}/i

      def self.included(klass)
        klass.class_eval do
          validates_with_method :ensure_type_parameter
          validates_with_method :ensure_data_parameter
          validates_with_method :ensure_samples_parameter
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
        data.each do |d|
          error = false
          case d
          when SampleCollectionData::String then error = true unless d.value.is_a?(String)
          when SampleCollectionData::Int then error = true unless d.value.is_a?(Integer)
          when SampleCollectionData::Url then error = true unless d.value =~ VALID_URL_PATTERN
          when SampleCollectionData::Uuid then error = true unless d.value =~ VALID_UUID_PATTERN
          when SampleCollectionData::Bool then error = true unless d.value.is_a?(TrueClass) || d.value.is_a?(FalseClass)
          else return [false, "Error found in data: '#{d.inspect}' isn't a valid SampleCollectionData."]
          end
          return error ? [false, "Type/value mismatch: '#{d.value}' is not a valid value for '#{d.class}'"] : [true]
        end
        [true]
      end

      def ensure_samples_parameter
        samples.each do |sample|
          unless sample.is_a?(Sample)
            return [false, "'#{sample.inspect}' is not a sample"]
          end
        end
        [true]
      end
    end
  end
end
