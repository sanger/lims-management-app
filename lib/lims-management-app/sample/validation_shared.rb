module Lims::ManagementApp
  class Sample
    module ValidationShared

      GENDER = ["Not applicable", "Male", "Female", "Mixed", "Hermaphrodite", "Unknown"]
      SAMPLE_TYPE = ["DNA Human", "DNA Pathogen", "RNA", "Blood", "Saliva", "Tissue Non-Tumour", "Tissue Tumour", "Pathogen", "Cell Pellet"]
      HUMAN_SAMPLE_TAXON_ID = 9606
      HUMAN_SAMPLE_GENDER = GENDER - ["Not applicable"]
      STATES = [Sample::DRAFT_STATE, Sample::PUBLISHED_STATE]

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
        if state.nil? || STATES.include?(state)
          [true]
        else
          [false, "'#{state}' is not a valid state"]
        end
      end

      # @param [Sample] sample
      # @return [Array]
      def validate_published_data(sample, accessor=nil)
        accessor = lambda { |object, parameter| object.send(parameter) } unless accessor

        if accessor[sample, :state] == PUBLISHED_STATE
          gender_validator = lambda { validate_gender(accessor[sample, :gender]) }
          sample_type_validator = lambda { validate_sample_type(accessor[sample, :sample_type]) }
          gender_for_human_sample_validator = lambda { validate_gender_for_human_sample(accessor[sample, :taxon_id], accessor[sample, :gender]) }

          validation_errors = [].tap do |e|
            [
              {:attribute => "gender", :validator => gender_validator},
              {:attribute => "sample_type", :validator => sample_type_validator},
              {:attribute => "taxon_id", :validator => gender_for_human_sample_validator}
            ].each do |val|
              if accessor[sample, val[:attribute]]
                result = val[:validator].call
                unless result.first
                  e << result[1]
                end
              else
                e << "#{val[:attribute].capitalize} must be set"
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
        def ensure_published_data
          validate_published_data(self)
        end
      end
    end
  end
end
