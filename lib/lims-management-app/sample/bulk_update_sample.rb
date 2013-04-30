require 'lims-core/actions/action'
require 'lims-management-app/sample/action_shared'
require 'lims-management-app/sample/validation_shared'

module Lims::ManagementApp
  class Sample
    class BulkUpdateSample
      include Lims::Core::Actions::Action
      include ActionShared
      include ValidationShared

      attribute :sample_uuids, Array, :required => false
      attribute :sanger_sample_ids, Array, :required => false
      attribute :gender, String, :required => false
      attribute :sample_type, String, :required => false

      validates_with_method :ensure_sample_references

      def _call_in_session(session)
        samples = [].tap do |s|
          if sanger_sample_ids
            sanger_sample_ids.each do |id|
              s << session.sample[{:sanger_sample_id => id}]
            end
          else
            sample_uuids.each do |uuid|
              s << session[uuid]
            end
          end
        end
        _update(samples, session)
      end

      private

      def ensure_sample_references
        sample_uuids || sanger_sample_ids
      end
    end
  end
end