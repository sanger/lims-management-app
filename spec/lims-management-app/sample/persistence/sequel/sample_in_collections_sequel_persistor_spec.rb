require 'lims-management-app/sample-collection/persistence/sequel/spec_helper'
require 'lims-management-app/sample-collection/persistence/sequel/sample_collection_sequel_shared'
require 'lims-management-app/sample-collection/delete_sample_collection'
require 'integrations/spec_helper'

module Lims::ManagementApp
  describe "a sample in sample collections" do
    include_context "sequel store"
    include_context "collection sequel factory"

    let(:sample_collection_uuid) { "11111111-2222-0000-2222-111111111111" }
    let!(:sample_collection) { new_sequel_sample_collection(sample_collection_uuid, sample_collection_action_sample_uuids) }  

    context "sample is reloadable with the sample collections it belongs to" do
      let(:sample_uuid) { "11111111-0000-0000-0000-222222222222" }  

      it "reloads the sample with the sample collections" do
        store.with_session do |session|
          sample = session[sample_uuid]
          sample.sample_collections.size.should == 1 
          session.uuid_for(sample.sample_collections[0]).should == sample_collection_uuid
        end
      end
    end
  end
end

