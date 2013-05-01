require 'lims-management-app/sample/bulk_update_sample'
require 'lims-management-app/sample/sample_shared'
require 'lims-management-app/spec_helper'
require 'integrations/spec_helper'

module Lims::ManagementApp
  describe Sample::BulkUpdateSample do
    shared_examples_for "bulk updating samples" do
      it_behaves_like "an action"

      it "updates sample objects" do
        samples = result[:samples]
        samples.should be_a(Array)
        samples.size.should == 2
        samples.each do |sample|
          sample.should be_a(Sample)
          sample.supplier_sample_name.should == "new sample name"
        end
      end

      it do
        pending "needs to be improved"
      end
    end

    include_context "sample factory"
    include_context "for application", "sample creation"
    include_context "sequel store"
    let(:parameters) { 
      {
        :store => store, 
        :user => user, 
        :application => application,
        :sample_uuids => [mock(:sample_uuid1), mock(:sample_uuid2)],
        :sanger_sample_ids => [mock(:id1), mock(:id2)]
      }
    }

    context "invalid action" do
      it "requires sample uuids or sanger sample ids" do
        described_class.new(parameters - [:sample_uuids, :sanger_sample_ids]).valid?.should == false
      end
    end


    context "valid action" do
      let(:result) { subject.call }

      context "with sample uuids" do
       subject {
          described_class.new(:store => store, :user => user, :application => application) do |a,s|
            a.sample_uuids = sample_uuids
            a.supplier_sample_name = "new sample name"
          end
        }

        it "has valid parameters" do
          described_class.new(parameters - [:sanger_sample_ids]).valid?.should == true
        end

        context "with valid sample uuids" do
          let!(:sample_uuids) do
            [new_common_sample, new_common_sample].map do |sample|
              store.with_session do |session|
                session << sample
                uuid = session.uuid_for!(sample)
                lambda { uuid }
              end.call
            end
          end
          it_behaves_like "bulk updating samples"
        end

        context "with invalid sample uuids" do
          let!(:sample_uuids) do
            uuid1 = store.with_session do |session|
              sample = new_common_sample
              session << sample
              uuid = session.uuid_for!(sample)
              lambda { uuid }
            end.call
            [uuid1, "dummy_uuid"]
          end

          it "raises an exception" do
            expect {
              subject.call
            }.to raise_error(Sample::BulkUpdateSample::SampleUuidNotFound)
          end
        end
      end


      context "with sanger sample ids" do
        subject {
          described_class.new(:store => store, :user => user, :application => application) do |a,s|
            a.sanger_sample_ids = sanger_sample_ids
            a.supplier_sample_name = "new sample name"
          end
        }

        it "has valid parameters" do
          described_class.new(parameters - [:sample_uuids]).valid?.should == true
        end

        context "with valid sanger sample ids" do
          let!(:sanger_sample_ids) do
            [new_common_sample, new_common_sample].map do |sample|
              store.with_session do |session|
                session << sample
                sample.generate_sanger_sample_id
                lambda { sample.sanger_sample_id }
              end.call
            end
          end
          it_behaves_like "bulk updating samples"
        end

        context "with invalid sanger sample ids" do
          let!(:sanger_sample_ids) do
            id1 = store.with_session do |session|
              sample = new_common_sample
              session << sample
              sample.generate_sanger_sample_id
              lambda { sample.sanger_sample_id }
            end.call
            [id1, "dummy_id"]
          end

          it "raises an exception" do
            expect {
              subject.call
            }.to raise_error(Sample::BulkUpdateSample::SangerSampleIdNotFound)
          end
        end
      end
    end
  end
end
