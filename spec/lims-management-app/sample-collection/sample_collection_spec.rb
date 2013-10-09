require 'lims-management-app/spec_helper'
require 'lims-management-app/sample-collection/sample_collection_shared'

module Lims::ManagementApp
  describe SampleCollection do

    # Macros
    def self.it_has_a(attribute, type = nil)
      it "responds to #{attribute}" do
        subject.should respond_to(attribute)
      end

      it "can assign #{attribute}" do
        value = mock(:attribute)
        subject.send("#{attribute}=", value)
        subject.send(attribute).should == value
      end
    end
    # End Macros

    context "valid" do
      include_context "collection factory"

      subject { new_sample_collection }

      it "is a valid sample collection" do
        subject.valid?.should == true
      end

      it "is a valid sample collection without data" do
        described_class.new(:type => "Study").valid?.should == true
      end

      it_has_a :type
      it_has_a :data
      it_has_a :samples
    end


    context "invalid" do
      it "is invalid without a type" do
        SampleCollection.new.valid?.should == false
      end

      it "is invalid if the type is wrong" do
        SampleCollection.new({:type => "dummy"}).valid?.should == false
      end

      it "is invalid if the data is not a SampleCollectionData object" do
        SampleCollection.new({:type => "study", :data => [{"dummy" => "test"}]}).valid?.should == false
      end

      it "is invalid if a SampleCollectionData::Int contains an invalid value" do
        SampleCollection.new({:type => "study", :data => [SampleCollection::SampleCollectionData::Int.new(:key => "test", :value => "string")]}).valid?.should == false
      end

      it "is invalid if a SampleCollectionData::String contains an invalid value" do
        SampleCollection.new({:type => "study", :data => [SampleCollection::SampleCollectionData::String.new(:key => "test", :value => 1)]}).valid?.should == false
      end

      it "is invalid if a SampleCollectionData::Url contains an invalid value" do
        SampleCollection.new({:type => "study", :data => [SampleCollection::SampleCollectionData::Url.new(:key => "test", :value => 1)]}).valid?.should == false
      end

      it "is invalid if a SampleCollectionData::Uuid contains an invalid value" do
        SampleCollection.new({:type => "study", :data => [SampleCollection::SampleCollectionData::Uuid.new(:key => "test", :value => 1)]}).valid?.should == false
      end

      it "is invalid if a SampleCollectionData::Bool contains an invalid value" do
        SampleCollection.new({:type => "study", :data => [SampleCollection::SampleCollectionData::Bool.new(:key => "test", :value => "string")]}).valid?.should == false
      end

      it "is invalid if the samples parameter contains something else than samples" do
        SampleCollection.new({:type => "study", :samples => [1,2,3]}).valid?.should == false
      end
    end
  end
end
