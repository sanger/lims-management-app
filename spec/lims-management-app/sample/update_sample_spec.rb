require 'lims-management-app/sample/update_sample'
require 'lims-management-app/sample/sample_shared'
require 'lims-management-app/spec_helper'

module Lims::ManagementApp
  describe Sample::UpdateSample do
    shared_examples_for "updating a sample" do
      include_context "create object"
      it_behaves_like "an action"

      it "updates a sample object" do
        Lims::Core::Persistence::Session.any_instance.should_receive(:save)
        result = subject.call
        sample = result[:sample]
        sample.should be_a(Sample)
        sample.gender.should == new_gender
        sample.sample_type.should == new_sample_type
        sample.dna.sample_purified.should == new_dna[:sample_purified]
        sample.dna.concentration.should == 100
      end

      it do
        pending "needs to be improved"
      end
    end

    include_context "sample factory"
    include_context "for application", "sample update"
    let(:new_gender) { "Female" }
    let(:new_sample_type) { "DNA Pathogen" }
    let(:new_dna) { {:sample_purified => false} }
    let(:parameters) { 
      {
        :store => store, 
        :user => user, 
        :application => application,
        :sample => new_common_sample
      }
    }

    context "invalid action" do
      it "requires a sample or a sanger sample id" do
        described_class.new(parameters - [:sample, :sanger_sample_id]).valid?.should == false
      end
    end


    context "valid action given a sample" do
      subject {
        described_class.new(:store => store, :user => user, :application => application) do |a,s|
          a.sample = new_sample_with_dna_rna_cellular
          a.gender = new_gender
          a.sample_type = new_sample_type
          a.dna = new_dna
        end
      }

      it "is valid" do
        described_class.new(parameters).valid?.should == true
      end

      it_behaves_like "updating a sample"
    end

    context "valid action given a sanger sample id" do
      pending "to finish"
#      subject {
#        described_class.new(:store => store, :user => user, :application => application) do |a,s|
#          a.sanger_sample_id = new_sample_with_dna_rna_cellular.tap do |sample|
#            sample.generate_sanger_sample_id
#          end.sanger_sample_id
#          a.gender = new_gender
#          a.sample_type = new_sample_type
#          a.dna = new_dna
#        end
#      }
#
#      it "is valid" do
#        pending "to fix"
#        described_class.new(parameters).valid?.should == true
#      end
#
#      it_behaves_like "updating a sample"
    end
  end
end
