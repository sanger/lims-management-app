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

    shared_examples_for "sequel bulk updating samples" do |samples_quantity=0, dna_quantity=0, rna_quantity=0, cellular_material_quantity=0, genotyping_quantity=0|
      it_behaves_like "changing the table", :samples, samples_quantity
      it_behaves_like "changing the table", :dna, dna_quantity
      it_behaves_like "changing the table", :rna, rna_quantity
      it_behaves_like "changing the table", :cellular_material, cellular_material_quantity
      it_behaves_like "changing the table", :genotyping, genotyping_quantity
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
        subject {
          described_class.new(:store => store, :user => user, :application => application) do |a,s|
            a.sample_uuids = sample_uuids
            a.dna = {:pre_amplified => true, :extraction_method => "method"} 
            a.rna = {:pre_amplified => true, :extraction_method => "method"} 
            a.cellular_material = {:lysed => true}
          end
        }
        it_behaves_like "sequel bulk updating samples", 0, 2, 2, 2
      end

      context "with dna, rna, cellular material attributes updating samples with dna, rna and cellular material" do
        let(:samples) { [new_sample_with_dna_rna_cellular, new_sample_with_dna_rna_cellular] }
        subject {
          described_class.new(:store => store, :user => user, :application => application) do |a,s|
            a.sample_uuids = sample_uuids
            a.dna = {:pre_amplified => true, :extraction_method => "method"} 
            a.rna = {:pre_amplified => true, :extraction_method => "method"} 
            a.cellular_material = {:lysed => true}
          end
        }
        it_behaves_like "sequel bulk updating samples", 0, 0, 0, 0
      end

      context "with genotyping attributes updating samples with dna, rna and cellular material" do
        let(:samples) { [new_sample_with_dna_rna_cellular, new_sample_with_dna_rna_cellular] }
        subject {
          described_class.new(:store => store, :user => user, :application => application) do |a,s|
            a.sample_uuids = sample_uuids
            a.genotyping = genotyping_parameters 
          end
        }
        it_behaves_like "sequel bulk updating samples", 0, 0, 0, 0, 2
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
        subject {
          described_class.new(:store => store, :user => user, :application => application) do |a,s|
            a.sanger_sample_ids = sanger_sample_ids
            a.supplier_sample_name = "new sample name"
          end
        }
        it_behaves_like "sequel bulk updating samples", 0, 0, 0, 0
      end

      context "with dna, rna, cellular material attributes updating common samples" do
        let(:samples) { [new_common_sample, new_common_sample] }
        subject {
          described_class.new(:store => store, :user => user, :application => application) do |a,s|
            a.sanger_sample_ids = sanger_sample_ids
            a.dna = {:pre_amplified => true, :extraction_method => "method"} 
            a.rna = {:pre_amplified => true, :extraction_method => "method"} 
            a.cellular_material = {:lysed => true}
          end
        }
        it_behaves_like "sequel bulk updating samples", 0, 2, 2, 2
      end

      context "with dna, rna, cellular material attributes updating samples with dna, rna and cellular material" do
        let(:samples) { [new_sample_with_dna_rna_cellular, new_sample_with_dna_rna_cellular] }
        subject {
          described_class.new(:store => store, :user => user, :application => application) do |a,s|
            a.sanger_sample_ids = sanger_sample_ids
            a.dna = {:pre_amplified => true, :extraction_method => "method"} 
            a.rna = {:pre_amplified => true, :extraction_method => "method"} 
            a.cellular_material = {:lysed => true}
          end
        }
        it_behaves_like "sequel bulk updating samples", 0, 0, 0, 0
      end

      context "with genotyping attributes updating samples with dna, rna and cellular material" do
        let(:samples) { [new_sample_with_dna_rna_cellular, new_sample_with_dna_rna_cellular] }
        subject {
          described_class.new(:store => store, :user => user, :application => application) do |a,s|
            a.sanger_sample_ids = sanger_sample_ids
            a.genotyping = genotyping_parameters 
          end
        }
        it_behaves_like "sequel bulk updating samples", 0, 0, 0, 0, 2
      end
    end
  end
end
