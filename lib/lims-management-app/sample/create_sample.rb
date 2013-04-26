require 'lims-core/actions/action'
require 'lims-management-app/sample/sample'
require 'lims-management-app/sample/create_action_shared'
require 'lims-management-app/sample/validation_shared'

module Lims::ManagementApp
  class Sample
    class CreateSample
      include Lims::Core::Actions::Action
      include CreateActionShared
      include ValidationShared

      def _call_in_session(session)
        _create(session)
      end
    end

    Create = CreateSample
  end
end
