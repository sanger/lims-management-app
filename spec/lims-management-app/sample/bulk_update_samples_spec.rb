require 'lims-management-app/sample/bulk_update_samples'
require 'lims-management-app/sample/sample_shared'
require 'lims-management-app/spec_helper'
require 'integrations/spec_helper'

module Lims::ManagementApp
  describe Sample::BulkUpdateSamples do
    shared_examples_for "bulk updating samples" do
      it_behaves_like "an action"

      it "updates sample objects" do
        samples = result[:samples]
        samples.should be_a(Array)
        samples.size.should == 2
        samples.each do |sample|
          sample.should be_a(Sample)
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
    end

    include_context "sample factory"
    include_context "for application", "sample creation"
    include_context "sequel store"
    let(:parameters) { 
      {
        :store => store, 
        :user => user, 
        :application => application,
        :by => "sanger_sample_id",
        :updates => {}
      }
    }

    context "invalid action" do
      it "requires a valid by attribute" do
        described_class.new(parameters.merge({:by => "dummy"})).valid?.should == false
      end

      it "requires a updates hash" do
        described_class.new(parameters - [:udpates]).valid?.should == false
      end
    end


    context "valid action" do
      let(:result) { subject.call }
      let(:updated_parameters) do
        {}.tap do |updates|
          sample_uuids.each do |uuid|
            updates[uuid] = full_sample_parameters
          end
        end
      end

      context "with sample uuids" do
       subject {
          described_class.new(:store => store, :user => user, :application => application) do |a,s|
            a.sample_uuids = sample_uuids
            updated_parameters.each do |k,v|
              a.send("#{k}=", v)
            end
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
            }.to raise_error(Sample::BulkUpdateSamples::SampleUuidNotFound)
          end
        end
      end


      context "with sanger sample ids" do
        subject {
          described_class.new(:store => store, :user => user, :application => application) do |a,s|
            a.sanger_sample_ids = sanger_sample_ids
            updated_parameters.each do |k,v|
              a.send("#{k}=", v)
            end
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
              lambda { sample.sanger_sample_id }
            end.call
            [id1, "dummy_id"]
          end

          it "raises an exception" do
            expect {
              subject.call
            }.to raise_error(Sample::BulkUpdateSamples::SangerSampleIdNotFound)
          end
        end
      end
    end
  end
end
