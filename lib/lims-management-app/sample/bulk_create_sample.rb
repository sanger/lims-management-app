require 'lims-core/actions/action'
require 'lims-management-app/sample/sample'
require 'lims-management-app/sample/action_shared'
require 'lims-management-app/sample/validation_shared'

module Lims::ManagementApp
  class Sample
    class BulkCreateSample
      include Lims::Core::Actions::Action
      include ActionShared
      include ValidationShared
      include ValidationShared::CommonValidator

      # If quantity is set to x, it creates x identical samples 
      # based on the given parameters.
      attribute :quantity, Numeric, :required => true
      validates_with_method :ensure_quantity_value
      attribute :state, String, :default => Sample::DRAFT_STATE, :required => false
      validates_with_method :ensure_published_data
      attribute :sanger_sample_id_core, String, :required => true

      def _call_in_session(session)
        _create(quantity, session)
      end

      private

      def ensure_quantity_value
        quantity ? quantity > 0 : true
      end
    end
  end
end
