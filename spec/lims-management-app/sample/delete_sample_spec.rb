require 'lims-management-app/sample/delete_sample'
require 'lims-management-app/sample/sample_shared'
require 'lims-management-app/spec_helper'
require 'integrations/spec_helper'

module Lims::ManagementApp
  describe Sample::DeleteSample do
    shared_examples_for "deleting a sample" do
      include_context "create object"
      it_behaves_like "an action"

      it "deletes a sample object" do
        Lims::Core::Persistence::Session.any_instance.should_receive(:delete)
        result = subject.call
        sample = result[:sample]
        sample.should be_a(Sample)
      end
    end

    include_context "sample factory"
    include_context "for application", "sample delete"
    let!(:store) { Lims::Core::Persistence::Store.new }
    let(:parameters) {
      {
        :store => store,
        :user => user,
        :application => application,
        :sample => new_common_sample
      }
    }


    context "invalid action" do
      it "requires a sample" do
        described_class.new(parameters - [:sample]).valid?.should == false
      end
    end


    context "valid action" do
      subject {
        described_class.new(:store => store, :user => user, :application => application) do |a,s|
          a.sample = new_common_sample
        end
      }

      it "is valid" do
        described_class.new(parameters).valid?.should == true
      end

      it_behaves_like "deleting a sample"
    end
  end
end
