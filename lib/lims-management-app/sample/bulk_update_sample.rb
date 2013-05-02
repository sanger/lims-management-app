require 'lims-core/actions/action'
require 'lims-management-app/sample/action_shared'
require 'lims-management-app/sample/validation_shared'

module Lims::ManagementApp
  class Sample
    class BulkUpdateSample
      include Lims::Core::Actions::Action
      include ActionShared
      include ValidationShared

      # The presence of sample_uuids or sanger_sample_ids is
      # checked with the ensure_samples_presence method.
      attribute :sample_uuids, Array, :required => false
      attribute :sanger_sample_ids, Array, :required => false
      attribute :gender, String, :required => false
      attribute :sample_type, String, :required => false
      attribute :taxon_id, Numeric, :required => false
      attribute :supplier_sample_name, String, :required => false
      attribute :common_name, String, :required => false
      validates_with_method :ensure_samples_presence

      def _call_in_session(session)
        samples = load_samples(session)
        _update(samples, session)
      end

      private

      def ensure_samples_presence
        sample_uuids || sanger_sample_ids
      end
    end
  end
end
