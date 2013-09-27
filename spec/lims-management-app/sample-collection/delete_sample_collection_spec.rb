require 'lims-management-app/sample-collection/delete_sample_collection'
require 'lims-management-app/sample-collection/sample_collection_shared'
require 'lims-management-app/sample-collection/spec_helper'

module Lims::ManagementApp
  describe SampleCollection::DeleteSampleCollection do
    include_context "collection factory"
    include_context "for application", "sample collection delete action"

    let!(:store) { Lims::Core::Persistence::Store.new }
    let(:parameters) {
      {
        :store => store,
        :application => application,
        :user => user
      }
    }

    context "when the action is not valid" do
      it "requires a sample collection" do
        described_class.new.valid?.should == false
      end
    end

    context "when the action is valid" do
      include_context "create object"
      it_behaves_like "an action"

      let(:sample_collection) { new_sample_collection }

      subject {
        described_class.new(parameters) do |a,s|
          a.sample_collection = sample_collection 
        end
      }

      it "has valid parameters" do
        described_class.new(parameters.merge({
          :sample_collection => sample_collection
        })).valid?.should == true
      end

      it "deletes a sample collection" do
        Lims::Core::Persistence::Session.any_instance.should_receive(:delete)
        result = subject.call
        collection = result[:sample_collection]
        collection.should be_a(SampleCollection)
      end
    end
  end
end
