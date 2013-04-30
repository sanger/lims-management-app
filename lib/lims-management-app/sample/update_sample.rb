require 'lims-core/actions/action'
require 'lims-management-app/sample/action_shared'
require 'lims-management-app/sample/validation_shared'

module Lims::ManagementApp
  class Sample
    class UpdateSample
      include Lims::Core::Actions::Action
      include ActionShared
      include ValidationShared

      attribute :sample, Sample, :required => false
      attribute :sanger_sample_id, String, :required => false
      attribute :gender, String, :required => false
      attribute :sample_type, String, :required => false

      validates_with_method :ensure_sample_reference

      def _call_in_session(session)
        sample_to_update = sanger_sample_id ? session.sample[{:sanger_sample_id => sanger_sample_id}] : sample
        _update([sample_to_update], session)
      end

      private

      def ensure_sample_reference
        sample || sanger_sample_id
      end
    end

    Update = UpdateSample
  end
end
