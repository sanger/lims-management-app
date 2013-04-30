require 'lims-management-app/sample/bulk_create_sample'
require 'lims-management-app/sample/sample_shared'
require 'lims-management-app/spec_helper'

module Lims::ManagementApp
  describe Sample::BulkCreateSample do
    shared_examples_for "bulk creating samples" do
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
        end
      end
    end

    include_context "sample factory"
    include_context "for application", "sample creation"
    let!(:store) { Lims::Core::Persistence::Store.new }
    let(:quantity) { 3 }
    let(:parameters) { 
      {
        :store => store, 
        :user => user, 
        :application => application,
        :quantity => quantity
      }.merge(full_sample_parameters) 
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
          full_sample_parameters.each do |k,v|
            a.send("#{k}=", v)
          end
          a.quantity = quantity
        end
      }

      it "has valid parameters" do
        described_class.new(parameters).valid?.should == true
      end

     it_behaves_like "bulk creating samples"
    end
  end
end
