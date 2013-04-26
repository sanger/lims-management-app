require 'lims-management-app/sample/create_bulk_sample'
require 'lims-management-app/spec_helper'

module Lims::ManagementApp
  describe Sample::CreateBulkSample do
    shared_examples_for "creating bulk samples" do
      include_context "create object"
      it_behaves_like "an action"

      it "creates sample objects" do
        Lims::Core::Persistence::Session.any_instance.should_receive(:save)
        result = subject.call
        samples = result[:samples]
        samples.should be_a(Array)
        samples.size.should == quantity
        samples.each do |sample|
          sample.should be_a(Sample)
          sample.gender.should == gender
          sample.sample_type.should == sample_type
        end
      end
    end

    include_context "for application", "sample creation"
    let(:gender) { "Female" }
    let(:sample_type) { "DNA Pathogen" }
    let(:quantity) { 3 }
    let(:parameters) { 
      {
        :store => store, 
        :user => user, 
        :application => application,
        :quantity => quantity,
        :gender => gender,
        :sample_type => sample_type
      } 
    }

    context "invalid action" do
      it "requires a valid quantity" do
        described_class.new(parameters.merge({:quantity => -1})).valid?.should == false
      end

      it "requires a gender" do
        described_class.new(parameters - [:gender]).valid?.should == false
      end

      it "requires a valid gender" do
        described_class.new(parameters.merge({:gender => "dummy"})).valid?.should == false
      end

      it "requires a sample type" do
        described_class.new(parameters - [:sample_type]).valid?.should == false
      end

      it "requires a valid sample type" do
        described_class.new(parameters.merge({:sample_type => "dummy"})).valid?.should == false
      end
    end


    context "valid action" do
      subject {
        described_class.new(:store => store, :user => user, :application => application) do |a,s|
          a.gender = gender
          a.sample_type = sample_type
          a.quantity = quantity
        end
      }
      it_behaves_like "creating bulk samples"
    end
  end
end
