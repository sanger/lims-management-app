module Lims::ManagementApp
  class Sample
    module ValidationShared

      GENDER = ["Not applicable", "Male", "Female", "Mixed", "Hermaphrodite", "Unkown"]
      SAMPLE_TYPE = ["DNA Human", "DNA Pathogen", "RNA", "Blood", "Saliva", "Tissue Non-Tumour", "Tissue Tumour", "Pathogen"]

      def self.included(klass)
        klass.class_eval do
          validates_with_method :ensure_gender_value
          validates_with_method :ensure_sample_type_value
        end
      end

      # @return [Boolean]
      # Validate if gender value belongs to the gender enumeration
      # Case insensitive
      # TODO: for human samples, it must be something else than Not applicable and Unknown
      def ensure_gender_value
        if gender
          GENDER.map(&:downcase).include?(gender.downcase)
        else
          true
        end
      end

      # @return [Boolean]
      # Validate if sample_type value belongs to the sample_type enumeration
      # Case insensitive
      def ensure_sample_type_value
        if sample_type
          SAMPLE_TYPE.map(&:downcase).include?(sample_type.downcase)
        else
          true
        end
      end
    end
  end
end
