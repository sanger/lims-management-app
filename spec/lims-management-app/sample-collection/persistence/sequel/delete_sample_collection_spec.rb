require 'lims-management-app/sample-collection/persistence/sequel/spec_helper'
require 'lims-management-app/sample-collection/persistence/sequel/sample_collection_sequel_shared'
require 'lims-management-app/sample-collection/delete_sample_collection'
require 'integrations/spec_helper'

module Lims::ManagementApp
  describe SampleCollection::DeleteSampleCollection do
    include_context "sequel store"
    include_context "for application", "delete collection"
    include_context "collection sequel factory"

    let(:sample_collection_uuid) { "11111111-2222-0000-2222-111111111111" }
    let!(:sample_collection) { new_sequel_sample_collection(sample_collection_uuid, sample_collection_action_sample_uuids) }  

    context "with valid parameters" do
      subject {
        described_class.new(:store => store, :user => user, :application => application) do |a,s|
          a.sample_collection = s[sample_collection_uuid]
        end
      }

      it_behaves_like "changing the table", :collections, -1
      it_behaves_like "changing the table", :collections_samples, -3
      it_behaves_like "changing the table", :collection_data_string, -1
      it_behaves_like "changing the table", :collection_data_int, -1
      it_behaves_like "changing the table", :samples, 0
      it_behaves_like "changing the table", :collection_data_url, -1
      it_behaves_like "changing the table", :collection_data_bool, -1
      it_behaves_like "changing the table", :collection_data_uuid, -1
    end

    
    context "with invalid parameters" do
      context "with invalid sample uuids" do
        subject {
          described_class.new(:store => store, :user => user, :application => application) do |a,s|
          end
        }

        it "raises an exception" do
          expect do
            subject.call
          end.to raise_error(Lims::Core::Actions::Action::InvalidParameters)
        end
      end
    end
  end
end
