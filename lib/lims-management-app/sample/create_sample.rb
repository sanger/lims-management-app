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

      # required attributes
      attribute :gender, String, :required => true
      attribute :sample_type, String, :required => true
      attribute :taxon_id, Numeric, :required => true
      attribute :supplier_sample_name, String, :required => true
      attribute :common_name, String, :required => true

      def _call_in_session(session)
        _create(1, session)
      end
    end

    Create = CreateSample
  end
end
