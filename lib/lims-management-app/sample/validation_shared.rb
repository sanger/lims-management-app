module Lims::ManagementApp
  class Sample
    module ValidationShared

      GENDER = ["Not applicable", "Male", "Female", "Mixed", "Hermaphrodite", "Unknown"]
      SAMPLE_TYPE = ["DNA Human", "DNA Pathogen", "RNA", "Blood", "Saliva", "Tissue Non-Tumour", "Tissue Tumour", "Pathogen", "Cell Pellet"]
      HUMAN_SAMPLE_TAXON_ID = 9606
      HUMAN_SAMPLE_GENDER = GENDER - ["Not applicable"]
      STATES = [Sample::DRAFT_STATE, Sample::PUBLISHED_STATE]
      AGE_BAND_PATTERN = /^([0-9]{1,2})-([0-9]{1,3})$/

      private

      # @param [String] value
      # @return [Array]
      def validate_gender(value)
        if GENDER.map(&:downcase).include?(value.downcase)
          [true]
        else
          [false, "'#{value}' is not a valid gender"]
        end
      end

      # @param [String] value
      # @return [Array]
      def validate_sample_type(value)
        if SAMPLE_TYPE.map(&:downcase).include?(value.downcase)
          [true]
        else
          [false, "'#{value}' is not a valid sample type"]
        end
      end

      # @param [Integer] taxon_id
      # @param [String] gender
      # @return [Array]
      def validate_gender_for_human_sample(taxon_id, gender)
        if taxon_id == HUMAN_SAMPLE_TAXON_ID && gender && 
          !HUMAN_SAMPLE_GENDER.map(&:downcase).include?(gender.downcase)
          [false, "The taxon ID '#{taxon_id}' and the gender '#{gender}' do not match."]
        else
          [true]
        end
      end

      # @param [String] state
      # @return [Array]
      def validate_state(state)
        if STATES.include?(state)
          [true]
        else
          [false, "'#{state}' is not a valid state"]
        end
      end

      # @param [String] age_band
      # @return [Array]
      def validate_age_band(age_band)
        age_band_match = age_band.match(AGE_BAND_PATTERN)
        if age_band.nil? || (age_band_match && $1.to_i <= $2.to_i)
          [true]
        else
          [false, "'#{age_band}' is not a valid age band. Age band pattern example: '12-45'"]
        end
      end

      # @param [Sample] sample
      # @return [Array]
      def validate_published_data(sample)
        if sample.state == PUBLISHED_STATE
          gender_validator = lambda { validate_gender(sample.gender) }
          sample_type_validator = lambda { validate_sample_type(sample.sample_type) }
          gender_for_human_sample_validator = lambda { validate_gender_for_human_sample(sample.taxon_id, sample.gender) }

          validation_errors = [].tap do |e|
            [
              {:attribute => "gender", :validator => gender_validator},
              {:attribute => "sample_type", :validator => sample_type_validator},
              {:attribute => "taxon_id", :validator => gender_for_human_sample_validator}
            ].each do |val|
              if sample.send(val[:attribute])
                result = val[:validator].call
                unless result.first
                  e << result[1]
                end
              else
                e << "#{val[:attribute].capitalize} must be set."
              end
            end
          end

          valid = validation_errors.empty?
          valid ? [true] : [false, "The sample to be published is not valid. #{validation_errors.size} error(s) found: #{validation_errors.join(", ")}"]
        else
          [true]
        end
      end


      module CommonValidator
        def self.included(klass)
          klass.class_eval do
            validates_with_method :ensure_gender_value
            validates_with_method :ensure_sample_type_value
            validates_with_method :ensure_gender_for_human_sample
            validates_with_method :ensure_state
            validates_with_method :ensure_age_band
          end
        end

        # @return [Array]
        # Validate if gender value belongs to the gender enumeration
        # Case insensitive
        def ensure_gender_value
          gender ? validate_gender(gender) : [true]
        end

        # @return [Array]
        # Validate if sample_type value belongs to the sample_type enumeration
        # Case insensitive
        def ensure_sample_type_value
          sample_type ? validate_sample_type(sample_type) : [true]
        end

        # @return [Array]
        # The gender of the sample must be something other than
        # "not applicable" or "unkown" for human samples.
        # A human sample has a taxon id equals to 9606.
        def ensure_gender_for_human_sample
          validate_gender_for_human_sample(taxon_id, gender)
        end

        # @return [Array]
        def ensure_state
          state ? validate_state(state) : [true]
        end

        # @return [Array]
        def ensure_age_band
          age_band ? validate_age_band(age_band) : [true] 
        end

        # @return [Array]
        def ensure_published_data
          validate_published_data(self)
        end
      end
    end
  end
end
