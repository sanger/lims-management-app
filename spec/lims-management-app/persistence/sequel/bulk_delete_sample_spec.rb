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

    shared_examples_for "sequel bulk deleting samples" do
      context "common samples" do
        let(:samples) { [new_common_sample, new_common_sample] }
        it_behaves_like "changing the table", :samples, -2
        it_behaves_like "changing the table", :dna, 0
        it_behaves_like "changing the table", :rna, 0
        it_behaves_like "changing the table", :cellular_material, 0
        it_behaves_like "changing the table", :genotyping, 0
      end

      context "samples with dna" do
        let(:samples) { [new_sample_with_dna, new_sample_with_dna] }
        it_behaves_like "changing the table", :samples, -2
        it_behaves_like "changing the table", :dna, -2
        it_behaves_like "changing the table", :rna, 0
        it_behaves_like "changing the table", :cellular_material, 0
        it_behaves_like "changing the table", :genotyping, 0
      end

      context "samples with dna, rna and cellular material" do
        let(:samples) { [new_sample_with_dna_rna_cellular, new_sample_with_dna_rna_cellular] }
        it_behaves_like "changing the table", :samples, -2
        it_behaves_like "changing the table", :dna, -2
        it_behaves_like "changing the table", :rna, -2
        it_behaves_like "changing the table", :cellular_material, -2
        it_behaves_like "changing the table", :genotyping, 0
      end

      context "samples with everything" do
        let(:samples) { [new_full_sample, new_full_sample] }
        it_behaves_like "changing the table", :samples, -2
        it_behaves_like "changing the table", :dna, -2
        it_behaves_like "changing the table", :rna, -2
        it_behaves_like "changing the table", :cellular_material, -2
        it_behaves_like "changing the table", :genotyping, -2
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

      it_behaves_like "sequel bulk deleting samples"
    end

    context "with sanger sample ids" do
      let!(:sanger_sample_ids) do
        samples.map do |sample|
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

      it_behaves_like "sequel bulk deleting samples"
    end
  end
end
