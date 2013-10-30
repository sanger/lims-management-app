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
    let(:sample_uuid) { "11111111-0000-0000-0000-222222222222" }  

    context "when loading the sample" do
      it "reloads the sample with its sample collections" do
        store.with_session do |session|
          sample = session[sample_uuid]
          sample.sample_collections.size.should == 1 
          session.uuid_for(sample.sample_collections[0]).should == sample_collection_uuid
        end
      end
    end

    context "when deleting the sample" do
      it "deletes the rows in collections_samples table" do
        expect do
          store.with_session do |session|
            session.delete(session[sample_uuid])
          end
        end.to change { db[:collections_samples].count }.by(-1)
      end
    end
  end
end

