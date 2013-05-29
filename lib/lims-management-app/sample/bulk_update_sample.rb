require 'lims-core/actions/action'
require 'lims-management-app/sample/action_shared'
require 'lims-management-app/sample/validation_shared'

module Lims::ManagementApp
  class Sample
    class BulkUpdateSample
      include Lims::Core::Actions::Action
      include ActionShared
      include ValidationShared

      BY_ATTRIBUTE_VALUES = ["sanger_sample_id", "uuid"]
      UPDATE_ATTRIBUTES = ATTRIBUTES.merge({
        :gender => String, :sample_type => String, :taxon_id => Numeric,
        :supplier_sample_name => String, :scientific_name => String
      })

      attribute :by, String, :required => false
      attribute :updates, Hash, :default => {}, :required => true
      validates_with_method :ensure_by_value
      validates_with_method :ensure_updates_parameter

      def _call_in_session(session)
        samples_data = load_samples(session)
        updated_samples = []
        samples_data.each do |sample, parameters|
          updated_samples << _update(sample, parameters, session)[:sample]
        end

        {:samples => updated_samples}
      end

      private

      # @return [Bool]
      # If by is not nil, we check its value, otherwise returns true
      def ensure_by_value
        by ? BY_ATTRIBUTE_VALUES.include?(by.downcase) : true 
      end

      # @return [Bool]
      # Return false if one of the parameters is invalid.
      def ensure_updates_parameter
        updates.each do |_, parameters|
          parameters.each do |key, value|
            return false unless UPDATE_ATTRIBUTES.include?(key.to_sym.downcase)
            case key.to_sym
            when :gender then return false unless validate_gender(value)
            when :sample_type then return false unless validate_sample_type(value)
            when :taxon_id then return false unless validate_gender_for_human_sample(value, parameters[:gender] || parameters["gender"])
            end
          end
        end
        true
      end

      # @param [Session] session
      # Replace the key of updates parameter (which originally contain
      # either sample uuids or sanger sample ids) with the actual
      # sample object.
      def load_samples(session)
        sample_loader = lambda do |key|
          if by && by.downcase == "sanger_sample_id"
            sample_object = session.sample[{:sanger_sample_id => key}]
            raise SangerSampleIdNotFound, "Sanger sample id '#{key}' is invalid" unless sample_object
            sample_object
          else
            sample_object = session[key]
            raise SampleUuidNotFound, "Sample uuid '#{key}' is invalid" unless sample_object
            sample_object
          end
        end

        updates.mash { |key, value| [sample_loader[key], value] }
      end
    end
  end
end
