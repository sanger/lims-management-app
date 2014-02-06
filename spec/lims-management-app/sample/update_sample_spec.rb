require 'lims-management-app/sample/update_sample'
require 'lims-management-app/sample/sample_shared'
require 'lims-management-app/spec_helper'
require 'integrations/spec_helper'

module Lims::ManagementApp
  describe Sample::UpdateSample do
    shared_examples_for "updating a sample" do
      include_context "create object"
      it_behaves_like "an action"

      it "updates a sample object" do
        Lims::Core::Persistence::Session.any_instance.should_receive(:save_all)
        result = subject.call
        sample = result[:sample]
        sample.should be_a(Sample)
        sample.state.should == state
        updated_parameters.each do |k,v|
          v = DateTime.parse(v) if k.to_s =~ /date/
          if [:dna, :rna, :cellular_material, :genotyping].include?(k)
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
    include_context "for application", "sample update"
    let!(:store) { Lims::Core::Persistence::Store.new }
    let(:parameters) { 
      {
        :store => store, 
        :user => user, 
        :application => application,
        :sample => new_common_sample
      }.merge(common_sample_parameters)
    }
    let(:updated_parameters) { update_parameters(full_sample_parameters) }

    context "invalid action" do
      it "requires a sample" do
        described_class.new(parameters - [:sample]).valid?.should == false
      end

      it "requires a valid gender" do
        described_class.new(parameters.merge({:gender => "dummy"})).valid?.should == false
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

      it "requires a valid age band" do
        described_class.new(parameters.merge({:age_band => "dummy"})).valid?.should == false
      end

      it "requires a valid age band interval" do
        described_class.new(parameters.merge({:age_band => "45-10"})).valid?.should == false
      end

      it "raises an exception with invalid values and published state" do
        expect do
          described_class.new(:store => store, :user => user, :application => application) do |a,s|
            a.sample = new_full_sample.tap { |s| s.gender = nil }
            a.state = "published"
          end.call
        end.to raise_error(Lims::Core::Actions::Action::InvalidParameters)
      end
    end


    context "valid action given a sample" do
      context "with a draft state" do
        let(:state) { "draft" }
        subject {
          described_class.new(:store => store, :user => user, :application => application) do |a,s|
            a.sample = new_full_sample
            a.state = state
            updated_parameters.each do |k,v|
              a.send("#{k}=", v)
            end
          end
        }

        it "is valid" do
          described_class.new(parameters).valid?.should == true
        end

        it_behaves_like "updating a sample"
      end

      context "with a published state" do
        let(:state) { "published" }
        subject {
          described_class.new(:store => store, :user => user, :application => application) do |a,s|
            a.sample = new_full_sample
            a.state = state
            updated_parameters.each do |k,v|
              a.send("#{k}=", v)
            end
          end
        }

        it "is valid" do
          described_class.new(parameters).valid?.should == true
        end

        it_behaves_like "updating a sample"       
      end
    end
  end
end
