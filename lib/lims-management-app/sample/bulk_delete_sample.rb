require 'lims-core/actions/action'
require 'lims-management-app/sample/action_shared'

module Lims::ManagementApp
  class Sample
    class BulkDeleteSample
      include Lims::Core::Actions::Action
      include ActionShared

      # The presence of sample_uuids or sanger_sample_ids is
      # checked with the ensure_samples_presence method.
      attribute :sample_uuids, Array, :required => false
      attribute :sanger_sample_ids, Array, :required => false
      validates_with_method :ensure_sample_references

      def _call_in_session(session)
        samples = load_samples(session)
        _delete(samples, session)
      end

      private

      def load_samples(session)
        [].tap do |s|
          if sanger_sample_ids
            sanger_sample_ids.each do |id|
              sample_object = session.sample[{:sanger_sample_id => id}]
              raise SangerSampleIdNotFound, "Sanger sample id '#{id}' is invalid" unless sample_object
              s << sample_object 
            end
          else
            sample_uuids.each do |uuid|
              sample_object = session[uuid]
              raise SampleUuidNotFound, "Sample uuid '#{uuid}' is invalid" unless sample_object
              s << sample_object 
            end
          end
        end
      end

      def ensure_sample_references
        sample_uuids || sanger_sample_ids
      end
    end
  end
end
