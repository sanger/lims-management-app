require 'lims-management-app/sample-collection/update_sample_collection'
require 'lims-management-app/sample-collection/sample_collection_shared'
require 'lims-management-app/sample-collection/spec_helper'

module Lims::ManagementApp
  describe SampleCollection::UpdateSampleCollection do
    include_context "collection factory"
    include_context "for application", "sample collection update action"

    let!(:store) { Lims::Core::Persistence::Store.new }
    let(:parameters) {
      {
        :store => store,
        :application => application,
        :user => user
      }
    }

    context "when the action is not valid" do
      it "requires valid data types" do
        described_class.new(
          parameters.merge(sample_collection_action_parameters(:data => [
            {"key" => "key_string", "type" => "dummy", "value" => "value"}
          ]))
        ).valid?.should == false
      end

      it "requires data triple key/type/value" do
        described_class.new(
          parameters.merge(sample_collection_action_parameters(:data => [1]))
        ).valid?.should == false
      end
    end


    shared_examples_for "an updated sample collection" do
      it "has valid parameters" do
        described_class.new(parameters.merge({
          :sample_collection => sample_collection,
          :data => updated_data
        })).valid?.should == true
      end

      it "updates a sample collection" do
        Lims::Core::Persistence::Session.any_instance.should_receive(:save)
        result = subject.call
        collection = result[:sample_collection]
        collection.should be_a(SampleCollection)

        collection.data.size.should == 7
        collection.samples.size.should == 0

        collection.data[0].should be_a(SampleCollection::SampleCollectionData::String)
        collection.data[0].key.should == "key_string"
        collection.data[0].value.should == "value"
        collection.data[1].should be_a(SampleCollection::SampleCollectionData::Int)
        collection.data[1].key.should == "key_int"
        collection.data[1].value.should == 1 
        collection.data[2].should be_a(SampleCollection::SampleCollectionData::Url)
        collection.data[2].key.should == "key_url"
        collection.data[2].value.should == "http://www.sanger.ac.uk"
        collection.data[3].should be_a(SampleCollection::SampleCollectionData::Bool)
        collection.data[3].key.should == "key_bool"
        collection.data[3].value.should == false 
        collection.data[4].should be_a(SampleCollection::SampleCollectionData::Bool)
        collection.data[4].key.should == "key_bool2"
        collection.data[4].value.should == false 
        collection.data[5].should be_a(SampleCollection::SampleCollectionData::Uuid)
        collection.data[5].key.should == "key_uuid"
        collection.data[5].value.should == "11111111-2222-3333-4444-555555555555" 
        collection.data[6].should be_a(SampleCollection::SampleCollectionData::String)
        collection.data[6].key.should == "new key"
        collection.data[6].value.should == "new value"
      end
    end


    context "when the action is valid" do
      include_context "create object"
      it_behaves_like "an action"

      before do
        Lims::Core::Persistence::Session.any_instance.stub(:uuid_for)
      end

      let(:sample_collection) { new_sample_collection }
      subject {
        described_class.new(parameters) do |a,s|
          a.sample_collection = sample_collection 
          a.data = updated_data
        end
      }

      context "with data to update with an explit type" do
        let(:updated_data) {[
          {"key" => "new key", "type" => "string", "value" => "new value"},
          {"key" => "key_bool", "type" => "bool", "value" => false}
        ]}
        it_behaves_like "an updated sample collection"
      end

      context "with data to update without an explit type" do
        let(:updated_data) {[
          {"key" => "new key", "value" => "new value"},
          {"key" => "key_bool", "value" => false}
        ]}
        it_behaves_like "an updated sample collection"
      end

      context "with data containing type mismatch with an existing data" do
        let(:updated_data) {[
          {"key" => "new key", "value" => "new value"},
          {"key" => "key_bool", "value" => 123}
        ]}

        it "raises an exception" do
          expect do
            subject.call
          end.to raise_error(SampleCollection::UpdateSampleCollection::DataTypeMismatch)
        end
      end
    end
  end
end
