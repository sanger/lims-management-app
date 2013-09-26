require 'lims-management-app/sample-collection/persistence/sequel/spec_helper'
require 'lims-management-app/sample-collection/sample_collection_shared'
require 'lims-management-app/sample-collection/create_sample_collection'
require 'integrations/spec_helper'

module Lims::ManagementApp
  describe SampleCollection::CreateSampleCollection do
    include_context "sequel store"
    include_context "for application", "create collection"
    include_context "collection factory"

    context "with valid parameters" do
      subject {
        described_class.new(:store => store, :user => user, :application => application) do |a,s|
          a.type = "Study"
          a.data = sample_collection_action_data
          a.sample_uuids = sample_collection_action_sample_uuids
        end
      }

      let!(:sample_uuids) {
        sample_collection_action_sample_uuids.tap do |uuids|
          uuids.each do |uuid|
            store.with_session do |session|
              set_uuid(session, new_common_sample, uuid)
            end
          end
        end
      }

      it_behaves_like "changing the table", :collections, 1 
      it_behaves_like "changing the table", :collections_samples, 3
      it_behaves_like "changing the table", :collection_data_string, 1
      it_behaves_like "changing the table", :collection_data_int, 1
      it_behaves_like "changing the table", :collection_data_url, 1
      it_behaves_like "changing the table", :collection_data_bool, 1
      it_behaves_like "changing the table", :collection_data_uuid, 1
    end

    
    context "with invalid parameters" do

      context "with invalid sample uuids" do
        subject {
          described_class.new(:store => store, :user => user, :application => application) do |a,s|
            a.type = "Study"
            a.sample_uuids = sample_collection_action_sample_uuids
          end
        }

        it "raises an exception" do
          expect do
            subject.call
          end.to raise_error(SampleCollection::CreateSampleCollection::SampleNotFound)
        end
      end
    end
  end
end
