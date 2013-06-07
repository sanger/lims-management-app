require 'lims-management-app/sample/bulk_create_sample'
require 'lims-management-app/sample/sample_shared'
require 'lims-management-app/spec_helper'
require 'lims-core/persistence/store'

module Lims::ManagementApp
  describe Sample::BulkCreateSample do
    shared_examples_for "bulk creating samples" do
      include_context "create object"
      it_behaves_like "an action"

      it "has valid parameters" do
        described_class.new(parameters).valid?.should == true
      end

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
        :quantity => quantity,
        :sanger_sample_id_core => "prefix"
      }.merge(full_sample_parameters) 
    }

    before do
      Lims::ManagementApp::Sample::SangerSampleIdNumber::SangerSampleIdNumberPersistor.any_instance.stub(:generate_new_number) { 1 }
    end

    context "invalid action" do
      it "requires a valid quantity" do
        described_class.new(parameters.merge({:quantity => -1})).valid?.should == false
      end

      it "requires a valid gender" do
        described_class.new(parameters.merge({:gender => "dummy"})).valid?.should == false
      end

      it "requires a valid sample type" do
        described_class.new(parameters.merge({:sample_type => "dummy"})).valid?.should == false
      end

      it "requires a valid state" do
        described_class.new(parameters.merge({:state => "dummy"})).valid?.should == false
      end

      it "raises an exception with empty sample and published state" do
        expect do
          described_class.new(:store => store, :user => user, :application => application) do |a,s|
            a.state = "published"
            a.quantity = quantity
          end.call
        end.to raise_error(Lims::Core::Actions::Action::InvalidParameters)
      end

      it "raises an exception within valid values and published state" do
        expect do
          described_class.new(:store => store, :user => user, :application => application) do |a,s|
            full_sample_parameters.merge({:gender => nil}).each do |k,v|
              a.send("#{k}=", v)
            end
            a.state = "published"
            a.quantity = quantity
          end.call
        end.to raise_error(Lims::Core::Actions::Action::InvalidParameters)
      end
    end


    context "valid action" do
      context "empty sample" do
        subject {
          described_class.new(:store => store, :user => user, :application => application) do |a,s|
            a.quantity = quantity
            a.sanger_sample_id_core = "prefix"
          end
        }

        it_behaves_like "bulk creating samples"
      end

      context "sample with parameters and draft state" do
        let(:state) { "draft" }
        subject {
          described_class.new(:store => store, :user => user, :application => application) do |a,s|
            a.state = state 
            a.sanger_sample_id_core = "prefix"
            a.quantity = quantity
            full_sample_parameters.each do |k,v|
              a.send("#{k}=", v)
            end
          end
        }
        it_behaves_like "bulk creating samples"
      end

      context "sample with parameters and published state" do
        let(:state) { "published" }
        subject {
          described_class.new(:store => store, :user => user, :application => application) do |a,s|
            a.state = state
            a.sanger_sample_id_core = "prefix"
            a.quantity = quantity
            full_sample_parameters.each do |k,v|
              a.send("#{k}=", v)
            end
          end
        }
        it_behaves_like "bulk creating samples"
      end
    end
  end
end
