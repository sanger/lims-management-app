require 'lims-core/actions/action'
require 'lims-management-app/sample/action_shared'

module Lims::ManagementApp
  class Sample
    class BulkDeleteSamples
      include Lims::Core::Actions::Action
      include ActionShared

      # The presence of sample_uuids or sanger_sample_ids is
      # checked with the ensure_samples_presence method.
      attribute :sample_uuids, Array, :required => false
      attribute :sanger_sample_ids, Array, :required => false
      validates_with_method :ensure_samples_presence

      def _call_in_session(session)
        samples = load_samples(session)
        _delete(samples, session)
      end

      private

      def ensure_samples_presence
        sample_uuids || sanger_sample_ids
      end
    end
  end
end
