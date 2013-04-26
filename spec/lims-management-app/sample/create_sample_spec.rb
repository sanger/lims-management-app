require 'lims-management-app/sample/create_sample'
require 'lims-management-app/spec_helper'

module Lims::ManagementApp
  describe Sample::CreateSample do
    shared_examples_for "creating a sample" do
      include_context "create object"
      it_behaves_like "an action"

      it "creates a sample object" do
        Persistence::Session.any_instance.should_receive(:save)
        result = subject.call
        sample = result[:sample]
        sample.should be_a(Sample)
      end
    end

    include_context "for application", "sample creation"
    let(:gender) { "Female" }
    let(:sample_type) { "DNA Pathogen" }
    let(:parameters) { 
      {
        :store => store, 
        :user => user, 
        :application => application,
        :gender => gender,
        :sample_type => sample_type
      } 
    }

    context "invalid action" do
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
      pending
    end
  end
end
