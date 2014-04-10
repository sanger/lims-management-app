require 'lims-management-app/sample/bulk_delete_sample'
require 'lims-management-app/sample/sample_shared'
require 'lims-management-app/sample/bulk_sample_shared'
require 'lims-management-app/spec_helper'
require 'integrations/spec_helper'

module Lims::ManagementApp
  describe Sample::BulkDeleteSample do
    shared_examples_for "bulk deleting samples" do
      it_behaves_like "an action"
      it_behaves_like "creates an array of sample objects"
    end

    include_context "create parameters"

    include_context "invalid action"

    include_context "valid action",
      "bulk deleting samples",
      Sample::BulkDeleteSample::SampleUuidNotFound,
      Sample::BulkDeleteSample::SangerSampleIdNotFound
  end
end
