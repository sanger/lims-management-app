require 'lims-management-app/sample/create_sample'
require 'lims-management-app/sample/sample_shared'
require 'lims-management-app/spec_helper'
require 'time'

module Lims::ManagementApp
  describe Sample::CreateSample do
    shared_examples_for "creating a sample" do
      include_context "create object"
      it_behaves_like "an action"

      it "creates a sample object" do
        Lims::Core::Persistence::Session.any_instance.should_receive(:save)
        result = subject.call
        sample = result[:sample]
        sample.should be_a(Sample)
        full_sample_parameters.each do |k,v|
          if [:dna, :rna, :cellular_material].include?(k)
            v.each do |k2,v2|
              sample.send(k).send(k2).to_s.should == v2.to_s
            end
          else
            sample.send(k).to_s.should == v.to_s
          end
        end
      end
    end

    include_context "sample factory"
    include_context "for application", "sample creation"
    let!(:store) { Lims::Core::Persistence::Store.new }
    let(:parameters) { 
      {
        :store => store, 
        :user => user, 
        :application => application
      }.merge(common_sample_parameters) 
    }

    context "invalid action" do
      it "requires a gender" do
        described_class.new(parameters - [:gender]).valid?.should == false
      end

      it "requires a valid gender" do
        described_class.new(parameters.merge({:gender => "dummy"})).valid?.should == false
      end

      it "is invalid if a human sample has a unknown gender" do
        described_class.new(parameters.merge({:taxon_id => 9606, :gender => "Unknown"})).valid?.should == false
      end

      it "is invalid if a human sample has a not applicable gender" do
        described_class.new(parameters.merge({:taxon_id => 9606, :gender => "Not applicable"})).valid?.should == false
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
        end
      }

      it "has valid parameters" do
        described_class.new(parameters).valid?.should == true
      end

      it_behaves_like "creating a sample"
    end
  end
end
