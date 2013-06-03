require 'lims-management-app/sample/create_sample'
require 'lims-management-app/sample/sample_shared'
require 'lims-management-app/spec_helper'
require 'lims-core/persistence/store'
require 'time'

module Lims::ManagementApp
  describe Sample::CreateSample do
    shared_examples_for "creating a sample" do
      include_context "create object"
      it_behaves_like "an action"

      it "has valid parameters" do
        described_class.new(parameters).valid?.should == true
      end

      it "creates a sample object" do
        Lims::Core::Persistence::Session.any_instance.should_receive(:save)
        result = subject.call
        sample = result[:sample]
        sample.should be_a(Sample)
        full_sample_parameters.each do |k,v|
          if [:dna, :rna, :cellular_material, :genotyping].include?(k)
            v.each do |k2,v2|
              sample.send(k).send(k2).to_s.should == v2.to_s
            end
          else
            sample.send(k).to_s.should == v.to_s
          end
        end
        sample.state.should == state
      end
    end

    shared_examples_for "creating an empty sample" do
      include_context "create object"
      it_behaves_like "an action"

      it "has valid parameters" do
        described_class.new(parameters).valid?.should == true
      end

      it "creates a sample object" do
        Lims::Core::Persistence::Session.any_instance.should_receive(:save)
        result = subject.call
        sample = result[:sample]
        sample.should be_a(Sample)
        sample.state.should == "draft"
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
      it "requires a valid gender" do
        described_class.new(parameters.merge({:gender => "dummy"})).valid?.should == false
      end

      it "is invalid if a human sample has a unknown gender" do
        described_class.new(parameters.merge({:taxon_id => 9606, :gender => "Unknown"})).valid?.should == false
      end

      it "is invalid if a human sample has a not applicable gender" do
        described_class.new(parameters.merge({:taxon_id => 9606, :gender => "Not applicable"})).valid?.should == false
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
          end.call
        end.to raise_error(Lims::Core::Actions::Action::InvalidParameters)
      end

      it "raises an exception with invalid values and published state" do
        expect do
          described_class.new(:store => store, :user => user, :application => application) do |a,s|
            full_sample_parameters.each do |k,v|
              a.send("#{k}=", v)
            end
            a.gender = nil 
            a.state = "published"
          end.call
        end.to raise_error(Lims::Core::Actions::Action::InvalidParameters)
      end
    end

    context "valid action" do
      context "empty sample" do
        subject {
          described_class.new(:store => store, :user => user, :application => application) do |a,s|
          end
        }

        it_behaves_like "creating an empty sample"
      end

      context "sample with parameters and draft state" do
        let(:state) { "draft" }
        subject {
          described_class.new(:store => store, :user => user, :application => application) do |a,s|
            a.state = state 
            full_sample_parameters.each do |k,v|
              a.send("#{k}=", v)
            end
          end
        }
        it_behaves_like "creating a sample"
      end

      context "sample with parameters and published state" do
        let(:state) { "published" }
        subject {
          described_class.new(:store => store, :user => user, :application => application) do |a,s|
            a.state = state
            full_sample_parameters.each do |k,v|
              a.send("#{k}=", v)
            end
          end
        }
        it_behaves_like "creating a sample"
      end
    end
  end
end
