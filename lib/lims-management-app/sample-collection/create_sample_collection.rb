require 'lims-core/actions/action'
require 'lims-management-app/sample-collection/sample_collection'
require 'lims-management-app/sample-collection/action_shared'
require 'lims-management-app/sample/action_shared'
require 'lims-management-app/sample/validation_shared'

module Lims::ManagementApp
  class SampleCollection
    class CreateSampleCollection
      include Lims::Core::Actions::Action
      include ValidationShared
      include ActionShared
      include Sample::ActionShared
      include Sample::ValidationShared

      SAMPLE_ATTRIBUTES = ATTRIBUTES.merge({
        :state => String, :quantity => Integer, :sanger_sample_id_core => String
      })

      attribute :type, String, :required => true
      attribute :data, Array, :required => false, :default => []
      attribute :samples, Hash, :required => false, :default => {}
      attribute :sample_uuids, Array, :required => false, :default => []
      validates_with_method :ensure_type_parameter
      validates_with_method :ensure_data_parameter
      validates_with_method :ensure_samples_quantity
      validates_with_method :ensure_samples_id_core
      validates_with_method :ensure_samples
      validates_with_method :ensure_published_samples

      def _call_in_session(session)
        collection_samples = []

        unless samples.empty?
          samples.delete("quantity").times do
            collection_samples << _create(session, samples)[:sample]
          end
        else
          collection_samples = prepared_samples(session)
        end

        collection = SampleCollection.new(:type => type, :data => prepared_data, :samples => collection_samples)
        session << collection
        {:sample_collection => collection, :uuid => session.uuid_for!(collection)}
      end

      private

      # @return [Array]
      def ensure_samples_quantity
        unless samples.empty?
          quantity = samples["quantity"]
          if quantity.nil?
            return [false, "The quantity of samples is required"]
          elsif quantity <= 0
            return [false, "The quantity '#{quantity}' is not valid"]
          end
        end
        [true]
      end

      # @return [Array]
      def ensure_samples_id_core
        unless samples.empty?
          sanger_sample_id_core = samples["sanger_sample_id_core"]
          return [false, "A Sanger sample id core is needed"] unless sanger_sample_id_core
        end
        [true]
      end


      # @return [Array]
      def ensure_samples
        errors, valid = [], true
        samples.each do |key, value|
          unless SAMPLE_ATTRIBUTES.include?(key.to_sym.downcase)
            valid = false
            errors << "Invalid parameter '#{key}'" 
          end

          result = case key.to_sym
                   when :gender then validate_gender(value)
                   when :sample_type then validate_sample_type(value)
                   when :taxon_id then validate_gender_for_human_sample(value, samples[:gender] || samples["gender"])
                   when :state then validate_state(value)
                   else [true]
                   end

          unless result[0]
            valid = false
            errors << result[1]
          end
        end

        valid ? [true] : [false, errors]       
      end

      def ensure_published_samples
        accessor = lambda { |object, parameter| object[parameter.to_sym] }
        validate_published_data(samples, accessor)
      end
    end

    Create = CreateSampleCollection
  end
end
