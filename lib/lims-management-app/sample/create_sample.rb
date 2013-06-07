require 'lims-core/actions/action'
require 'lims-management-app/sample/sample'
require 'lims-management-app/sample/action_shared'
require 'lims-management-app/sample/validation_shared'

module Lims::ManagementApp
  class Sample
    class CreateSample
      include Lims::Core::Actions::Action
      include ActionShared
      include ValidationShared
      include ValidationShared::CommonValidator

      attribute :sanger_sample_id_core, String, :required => true
      attribute :state, String, :default => Sample::DRAFT_STATE, :required => false
      validates_with_method :ensure_published_data

      def _call_in_session(session)
        _create(session)
      end
    end

    Create = CreateSample
  end
end
