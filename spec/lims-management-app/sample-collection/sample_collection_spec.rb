require 'lims-management-app/spec_helper'

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
      let(:collection_type) { "Study" }
      let(:collection_data) {[
        {"key" => "name", "type" => "string", "value" => "my name"},
        {"key" => "field1", "type" => "integer", "value" => 1},
        {"key" => "address", "type" => "url", "value" => "http://www.sanger.ac.uk"},
        {"key" => "something uuid", "type" => "uuid", "value" => "11111111-2222-3333-4444-555555555555"}
      ]}
      subject { described_class.new(:type => collection_type, :data => collection_data) }

      it "is a valid sample collection" do
        subject.valid?.should == true
      end

      it_has_a :type
      it_has_a :data
    end


    context "invalid" do
      it "is invalid without a type" do
        SampleCollection.new.valid?.should == false
      end

      it "is invalid if the type is wrong" do
        SampleCollection.new({:type => "dummy"}).valid?.should == false
      end

      it "is invalid if the data contains non triple" do
        SampleCollection.new({:type => "study", :data => [1]}).valid?.should == false
      end

      it "is invalid if the data is not a triple key/type/value" do
        SampleCollection.new({:type => "study", :data => [{"dummy" => "test"}]}).valid?.should == false
      end

      it "is invalid if the type is unknown" do
        SampleCollection.new({:type => "study", :data => [{"key" => "test", "type" => "dummy", "value" => "aaa"}]}).valid?.should == false
      end

      it "is invalid if the type integer does not match the value" do
        SampleCollection.new({:type => "study", :data => [{"key" => "test", "type" => "integer", "value" => "string"}]}).valid?.should == false
      end

      it "is invalid if the type string does not match the value" do
        SampleCollection.new({:type => "study", :data => [{"key" => "test", "type" => "string", "value" => 1}]}).valid?.should == false
      end

      it "is invalid if the type url does not match the value" do
        SampleCollection.new({:type => "study", :data => [{"key" => "test", "type" => "url", "value" => "sanger.ac.uk"}]}).valid?.should == false
      end

      it "is invalid if the type uuid does not match the value" do
        SampleCollection.new({:type => "study", :data => [{"key" => "test", "type" => "uuid", "value" => "123456"}]}).valid?.should == false
      end
    end
  end
end
