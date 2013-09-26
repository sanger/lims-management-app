require 'lims-management-app/spec_helper'
require 'lims-core/persistence/store'
require 'lims-management-app/sample-collection/sample_collection_shared'
require 'lims-management-app/sample-collection/create_sample_collection'

module Lims::ManagementApp
  describe SampleCollection::CreateSampleCollection do
    include_context "collection factory"
    include_context "for application", "collection creation"
    
    let!(:store) { Lims::Core::Persistence::Store.new }
    let(:parameters) {
      {
        :store => store,
        :application => application,
        :user => user
      }
    }
    
    context "when the action is not valid" do
      it "requires a type" do
        described_class.new(parameters).valid?.should == false
      end

      it "requires a valid type" do
        described_class.new(parameters.merge(:type => "dummy")).valid?.should == false
      end

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


    context "when the action is valid" do
      include_context "create object"
      it_behaves_like "an action"

      let(:type) { "Study" }

      subject {
        described_class.new(parameters) do |a,s|
          a.type = "Study"
          a.data = sample_collection_action_data
          # we do not test sample_uuids here as it needs persistence
          # @see the corresponding spec in persistence
          a.sample_uuids = []
        end
      }

      it "has valid parameters" do
        described_class.new(parameters.merge({
          :type => type, 
          :data => sample_collection_action_data, 
          :sample_uuids => []
        })).valid?.should == true
      end

      it "creates a sample collection" do
        Lims::Core::Persistence::Session.any_instance.should_receive(:save)
        result = subject.call
        collection = result[:sample_collection]
        collection.should be_a(SampleCollection)

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
        collection.data[3].value.should == true 
        collection.data[4].should be_a(SampleCollection::SampleCollectionData::Uuid)
        collection.data[4].key.should == "key_uuid"
        collection.data[4].value.should == "11111111-2222-3333-4444-555555555555"
      end
    end
  end
end
