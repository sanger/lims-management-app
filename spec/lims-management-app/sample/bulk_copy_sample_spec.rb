require 'lims-management-app/sample/bulk_copy_sample'
require 'lims-management-app/sample/sample_shared'
require 'lims-management-app/sample/bulk_sample_shared'
require 'lims-management-app/spec_helper'
require 'integrations/spec_helper'

module Lims::ManagementApp
  describe Sample::BulkCopySample do
    shared_examples_for "bulk copying existing samples from S2 to Sequencescape" do
      it_behaves_like "an action"
      it_behaves_like "creates an array of sample objects"
    end

    include_context "create parameters"

    include_context "invalid action"

    include_context "valid action",
      "bulk copying existing samples from S2 to Sequencescape",
      Sample::BulkCopySample::SampleUuidNotFound,
      Sample::BulkCopySample::SangerSampleIdNotFound
  end
end
