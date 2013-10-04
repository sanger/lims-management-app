require 'lims-management-app/sample-collection/persistence/sequel/spec_helper'
require 'lims-management-app/sample-collection/persistence/sequel/sample_collection_sequel_shared'
require 'lims-management-app/sample-collection/update_sample_collection'
require 'integrations/spec_helper'

module Lims::ManagementApp
  describe SampleCollection::UpdateSampleCollection do
    include_context "sequel store"
    include_context "for application", "update collection"
    include_context "collection sequel factory"

    let(:sample_collection_uuid) { "11111111-2222-0000-2222-111111111111" }
    let!(:sample_collection) { new_sequel_sample_collection(sample_collection_uuid, sample_collection_action_sample_uuids) }  

    context "with valid parameters" do
      let(:updated_data) {[
        {"key" => "new key", "type" => "string", "value" => "new value"},
        {"key" => "key_bool", "type" => "bool", "value" => false}
      ]}

      let(:new_sample_uuids) {["11111111-0000-0000-0000-444444444444", "11111111-0000-0000-0000-555555555555"]}
      let(:updated_sample_uuids) {[
          "11111111-0000-0000-0000-111111111111",
          "11111111-0000-0000-0000-444444444444",
          "11111111-0000-0000-0000-555555555555",
      ]}

      let!(:samples_to_add) { new_sequel_samples(new_sample_uuids) }

      subject {
        described_class.new(:store => store, :user => user, :application => application) do |a,s|
          a.sample_collection = s[sample_collection_uuid]
          a.data = updated_data
          a.sample_uuids = updated_sample_uuids
        end
      }

      it_behaves_like "changing the table", :collections, 0
      it_behaves_like "changing the table", :collection_data_string, 1
      it_behaves_like "changing the table", :collection_data_int, 0
      it_behaves_like "changing the table", :samples, 0
      it_behaves_like "changing the table", :collection_data_url, 0
      it_behaves_like "changing the table", :collection_data_bool, 0
      it_behaves_like "changing the table", :collection_data_uuid, 0

      context "when 2 samples are added and 2 samples deleted" do
        it_behaves_like "changing the table", :collections_samples, 0
        it_behaves_like "changing the table", :samples, 0
      end

      context "when 2 samples are deleted" do
        let(:new_sample_uuids) { []}
        let(:updated_sample_uuids) {["11111111-0000-0000-0000-111111111111"]}
        it_behaves_like "changing the table", :collections_samples, -2
        it_behaves_like "changing the table", :samples, 0
      end

      context "when 2 samples are added" do
        let(:new_sample_uuids) { ["11111111-0000-0000-0000-444444444444", "11111111-0000-0000-0000-555555555555"]}
        let(:updated_sample_uuids) {["11111111-0000-0000-0000-111111111111","11111111-0000-0000-0000-222222222222","11111111-0000-0000-0000-333333333333","11111111-0000-0000-0000-444444444444","11111111-0000-0000-0000-555555555555"]}
        it_behaves_like "changing the table", :collections_samples, 2
        it_behaves_like "changing the table", :samples, 0
      end
    end

    
    context "with invalid parameters" do
      context "with invalid sample uuids" do
        subject {
          described_class.new(:store => store, :user => user, :application => application) do |a,s|
            a.sample_collection = s[sample_collection_uuid]
            a.sample_uuids = ["11111111-2222-1234-4567-123456789012"]
          end
        }

        it "raises an exception" do
          expect do
            subject.call
          end.to raise_error(SampleCollection::SampleNotFound)
        end
      end
    end
  end
end
