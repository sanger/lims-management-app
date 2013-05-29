module Lims::ManagementApp
  class Sample
    module ValidationShared

      GENDER = ["Not applicable", "Male", "Female", "Mixed", "Hermaphrodite", "Unknown"]
      SAMPLE_TYPE = ["DNA Human", "DNA Pathogen", "RNA", "Blood", "Saliva", "Tissue Non-Tumour", "Tissue Tumour", "Pathogen"]
      HUMAN_SAMPLE_TAXON_ID = 9606
      HUMAN_SAMPLE_GENDER = GENDER - ["Not applicable", "Unknown"]

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

        # @return [Boolean]
        # The gender of the sample must be something other than
        # "not applicable" or "unkown" for human samples.
        # A human sample has a taxon id equals to 9606.
        def ensure_gender_for_human_sample
          if taxon_id == HUMAN_SAMPLE_TAXON_ID
            HUMAN_SAMPLE_GENDER.map(&:downcase).include?(gender.downcase) if gender
          else
            true
          end
        end
      end
    end
  end
end
