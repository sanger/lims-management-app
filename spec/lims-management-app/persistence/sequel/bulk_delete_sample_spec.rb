require 'lims-management-app/persistence/sequel/spec_helper'
require 'lims-management-app/sample/bulk_delete_sample'
require 'lims-management-app/sample/sample_shared'
require 'lims-management-app/spec_helper'
require 'integrations/spec_helper'

module Lims::ManagementApp
  describe Sample::BulkDeleteSample do
    include_context "sample factory"
    include_context "for application", "bulk delete"
    include_context "sequel store"

    shared_examples_for "bulk deleting samples" do
      context "common samples" do
        let(:samples) { [new_common_sample, new_common_sample] }
        it "modify the samples table" do
          expect do
            subject.call
          end.to change { db[:samples].count }.by(-samples.size)
        end
      end

      context "samples with dna" do
        let(:samples) { [new_sample_with_dna, new_sample_with_dna] }
        it "modify the samples table" do
          expect do
            subject.call
          end.to change { db[:samples].count }.by(-samples.size)
        end

        it "modify the dna table" do
          expect do
            subject.call
          end.to change { db[:dna].count }.by(-samples.size)
        end
      end

      context "samples with dna, rna and cellular material" do
        let(:samples) { [new_sample_with_dna_rna_cellular, new_sample_with_dna_rna_cellular] }
        it "modify the samples table" do
          expect do
            subject.call
          end.to change { db[:samples].count }.by(-samples.size)
        end

        it "modify the dna table" do
          expect do
            subject.call
          end.to change { db[:dna].count }.by(-samples.size)
        end

        it "modify the rna table" do
          expect do
            subject.call
          end.to change { db[:rna].count }.by(-samples.size)
        end

        it "modify the cellular_material table" do
          expect do
            subject.call
          end.to change { db[:cellular_material].count }.by(-samples.size)
        end
      end
    end


    context "with sample uuids" do
      let!(:sample_uuids) do
        samples.map do |sample|
          store.with_session do |session|
            session << sample
            uuid = session.uuid_for!(sample)
            lambda { uuid }
          end.call
        end
      end

      subject {
        described_class.new(:store => store, :user => user, :application => application) do |a,s|
          a.sample_uuids = sample_uuids
        end
      }

      it_behaves_like "bulk deleting samples"
    end


    context "with sanger sample ids" do
      let!(:sanger_sample_ids) do
        [new_common_sample, new_common_sample].map do |sample|
          store.with_session do |session|
            session << sample
            sample.generate_sanger_sample_id
            lambda { sample.sanger_sample_id }
          end.call
        end
      end

      subject {
        described_class.new(:store => store, :user => user, :application => application) do |a,s|
          a.sanger_sample_ids = sanger_sample_ids
        end
      }

      it_behaves_like "bulk deleting samples"
    end
  end
end
