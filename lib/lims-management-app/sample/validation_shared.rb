module Lims::ManagementApp
  class Sample
    module ValidationShared

      GENDER = ["Not applicable", "Male", "Female", "Mixed", "Hermaphrodite", "Unknown"]
      SAMPLE_TYPE = ["DNA Human", "DNA Pathogen", "RNA", "Blood", "Saliva", "Tissue Non-Tumour", "Tissue Tumour", "Pathogen"]
      HUMAN_SAMPLE_TAXON_ID = 9606
      HUMAN_SAMPLE_GENDER = GENDER - ["Not applicable", "Unknown"]

      private

      def validate_gender(value)
        GENDER.map(&:downcase).include?(value.downcase)
      end

      def validate_sample_type(value)
        SAMPLE_TYPE.map(&:downcase).include?(value.downcase)
      end

      def validate_gender_for_human_sample(taxon_id, gender)
        if taxon_id == HUMAN_SAMPLE_TAXON_ID
          HUMAN_SAMPLE_GENDER.map(&:downcase).include?(gender.downcase) if gender
        else
          true
        end
      end

      module CommonValidator
        def self.included(klass)
          klass.class_eval do
            validates_with_method :ensure_gender_value
            validates_with_method :ensure_sample_type_value
            validates_with_method :ensure_gender_for_human_sample
          end
        end

        # @return [Boolean]
        # Validate if gender value belongs to the gender enumeration
        # Case insensitive
        def ensure_gender_value
          gender ? validate_gender(gender) : true
        end

        # @return [Boolean]
        # Validate if sample_type value belongs to the sample_type enumeration
        # Case insensitive
        def ensure_sample_type_value
          sample_type ? validate_sample_type(sample_type) : true
        end

        # @return [Boolean]
        # The gender of the sample must be something other than
        # "not applicable" or "unkown" for human samples.
        # A human sample has a taxon id equals to 9606.
        def ensure_gender_for_human_sample
          validate_gender_for_human_sample(taxon_id, gender)
        end
      end
    end
  end
end
