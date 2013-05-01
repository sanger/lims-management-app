require 'lims-management-app/persistence/sequel/spec_helper'
require 'lims-management-app/sample/bulk_update_sample'
require 'lims-management-app/sample/sample_shared'
require 'lims-management-app/spec_helper'
require 'integrations/spec_helper'

module Lims::ManagementApp
  describe Sample::BulkUpdateSample do
    include_context "sample factory"
    include_context "for application", "bulk update"
    include_context "sequel store"

    shared_examples_for "sequel bulk updating samples" do
      it "modify the samples table" do
        expect do
          subject.call
        end.to change { db[:samples].count }.by(samples_quantity)
      end

      it "modify the dna table" do
        expect do
          subject.call
        end.to change { db[:dna].count }.by(dna_quantity)
      end

      it "modify the rna table" do
        expect do
          subject.call
        end.to change { db[:rna].count }.by(rna_quantity)
      end

      it "modify the cellular_material table" do
        expect do
          subject.call
        end.to change { db[:cellular_material].count }.by(cellular_material_quantity)
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

      context "with common attribute update" do
        let(:samples) { [new_common_sample, new_common_sample] }
        let(:samples_quantity) { 0 }
        let(:dna_quantity) { 0 }
        let(:rna_quantity) { 0 }
        let(:cellular_material_quantity) { 0 }
        subject {
          described_class.new(:store => store, :user => user, :application => application) do |a,s|
            a.sample_uuids = sample_uuids
            a.supplier_sample_name = "new sample name"
          end
        }
        it_behaves_like "sequel bulk updating samples"
      end

      context "with dna, rna, cellular material attributes updating common samples" do
        let(:samples) { [new_common_sample, new_common_sample] }
        let(:samples_quantity) { 0 }
        let(:dna_quantity) { 2 }
        let(:rna_quantity) { 2 }
        let(:cellular_material_quantity) { 2 }
        subject {
          described_class.new(:store => store, :user => user, :application => application) do |a,s|
            a.sample_uuids = sample_uuids
            a.dna = {:pre_amplified => true, :extraction_method => "method"} 
            a.rna = {:pre_amplified => true, :extraction_method => "method"} 
            a.cellular_material = {:lysed => true}
          end
        }
        it_behaves_like "sequel bulk updating samples"
      end

      context "with dna, rna, cellular material attributes updating samples with dna, rna and cellular material" do
        let(:samples) { [new_sample_with_dna_rna_cellular, new_sample_with_dna_rna_cellular] }
        let(:samples_quantity) { 0 }
        let(:dna_quantity) { 0 }
        let(:rna_quantity) { 0 }
        let(:cellular_material_quantity) { 0 }
        subject {
          described_class.new(:store => store, :user => user, :application => application) do |a,s|
            a.sample_uuids = sample_uuids
            a.dna = {:pre_amplified => true, :extraction_method => "method"} 
            a.rna = {:pre_amplified => true, :extraction_method => "method"} 
            a.cellular_material = {:lysed => true}
          end
        }
        it_behaves_like "sequel bulk updating samples"
      end
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

      context "with common attribute update" do
        let(:samples) { [new_common_sample, new_common_sample] }
        let(:samples_quantity) { 0 }
        let(:dna_quantity) { 0 }
        let(:rna_quantity) { 0 }
        let(:cellular_material_quantity) { 0 }
        subject {
          described_class.new(:store => store, :user => user, :application => application) do |a,s|
            a.sanger_sample_ids = sanger_sample_ids
            a.supplier_sample_name = "new sample name"
          end
        }
        it_behaves_like "sequel bulk updating samples"
      end

      context "with dna, rna, cellular material attributes updating common samples" do
        let(:samples) { [new_common_sample, new_common_sample] }
        let(:samples_quantity) { 0 }
        let(:dna_quantity) { 2 }
        let(:rna_quantity) { 2 }
        let(:cellular_material_quantity) { 2 }
        subject {
          described_class.new(:store => store, :user => user, :application => application) do |a,s|
            a.sanger_sample_ids = sanger_sample_ids
            a.dna = {:pre_amplified => true, :extraction_method => "method"} 
            a.rna = {:pre_amplified => true, :extraction_method => "method"} 
            a.cellular_material = {:lysed => true}
          end
        }
        it_behaves_like "sequel bulk updating samples"
      end

      context "with dna, rna, cellular material attributes updating samples with dna, rna and cellular material" do
        let(:samples) { [new_sample_with_dna_rna_cellular, new_sample_with_dna_rna_cellular] }
        let(:samples_quantity) { 0 }
        let(:dna_quantity) { 0 }
        let(:rna_quantity) { 0 }
        let(:cellular_material_quantity) { 0 }
        subject {
          described_class.new(:store => store, :user => user, :application => application) do |a,s|
            a.sanger_sample_ids = sanger_sample_ids
            a.dna = {:pre_amplified => true, :extraction_method => "method"} 
            a.rna = {:pre_amplified => true, :extraction_method => "method"} 
            a.cellular_material = {:lysed => true}
          end
        }
        it_behaves_like "sequel bulk updating samples"
      end
    end
  end
end
