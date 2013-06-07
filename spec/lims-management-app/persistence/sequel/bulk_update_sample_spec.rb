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
            a.updates = {}.tap do |h|
              sample_uuids.each do |uuid|
                h[uuid] = {:supplier_sample_name => "new sample name"}
              end
            end
          end
        }
        it_behaves_like "sequel bulk updating samples"
      end

      context "with dna, rna, cellular material attributes updating common samples" do
        let(:samples) { [new_common_sample, new_common_sample] }
        subject {
          described_class.new(:store => store, :user => user, :application => application) do |a,s|
            a.updates = {}.tap do |h|
              sample_uuids.each do |uuid|
                h[uuid] = {:dna => {:pre_amplified => true, :extraction_method => "method"},
                           :rna => {:pre_amplified => true, :extraction_method => "method"},
                           :cellular_material => {:lysed => true}}
              end
            end
          end
        }
        it_behaves_like "sequel bulk updating samples", 0, 2, 2, 2
      end

      context "with dna, rna, cellular material attributes updating samples with dna, rna and cellular material" do
        let(:samples) { [new_sample_with_dna_rna_cellular, new_sample_with_dna_rna_cellular] }
        subject {
          described_class.new(:store => store, :user => user, :application => application) do |a,s|
            a.updates = {}.tap do |h|
              sample_uuids.each do |uuid|
                h[uuid] = {:dna => {:pre_amplified => true, :extraction_method => "method"},
                           :rna => {:pre_amplified => true, :extraction_method => "method"},
                           :cellular_material => {:lysed => true}}
              end
            end
          end
        }
        it_behaves_like "sequel bulk updating samples", 0, 0, 0, 0
      end

      context "with genotyping attributes updating samples with dna, rna and cellular material" do
        let(:samples) { [new_sample_with_dna_rna_cellular, new_sample_with_dna_rna_cellular] }
        subject {
          described_class.new(:store => store, :user => user, :application => application) do |a,s|
            a.updates = {}.tap do |h|
              sample_uuids.each do |uuid|
                h[uuid] = {:genotyping => genotyping_parameters}
              end
            end
          end
        }
        it_behaves_like "sequel bulk updating samples", 0, 0, 0, 0, 2
      end

      context "with empty samples and published state" do
        let(:samples) { [Sample.new, Sample.new] }
        subject {
          described_class.new(:store => store, :user => user, :application => application) do |a,s|
            a.updates = {}.tap do |h|
              sample_uuids.each do |uuid|
                h[uuid] = {:state => "published"}
              end
            end
          end
        }
        it "raises an error" do 
          expect do
            subject.call
          end.to raise_error(Lims::Core::Actions::Action::InvalidParameters)
        end
      end
    end



    context "with sanger sample ids" do
      let!(:sanger_sample_ids) do
        samples.each_with_index.map do |sample, i|
          store.with_session do |session|
            session << sample
            sample.sanger_sample_id = "s2-#{i}"
            lambda { sample.sanger_sample_id }
          end.call
        end
      end

      context "with common attribute update" do
        let(:samples) { [new_common_sample, new_common_sample] }
        subject {
          described_class.new(:store => store, :user => user, :application => application) do |a,s|
            a.by = "sanger_sample_id"
            a.updates = {}.tap do |h|
              sanger_sample_ids.each do |uuid|
                h[uuid] = {:supplier_sample_name => "new sample name"}
              end
            end           
          end
        }
        it_behaves_like "sequel bulk updating samples", 0, 0, 0, 0
      end

      context "with dna, rna, cellular material attributes updating common samples" do
        let(:samples) { [new_common_sample, new_common_sample] }
        subject {
          described_class.new(:store => store, :user => user, :application => application) do |a,s|
            a.by = "sanger_sample_id"
            a.updates = {}.tap do |h|
              sanger_sample_ids.each do |uuid|
                h[uuid] = {:dna => {:pre_amplified => true, :extraction_method => "method"},
                           :rna => {:pre_amplified => true, :extraction_method => "method"},
                           :cellular_material => {:lysed => true}}
              end
            end
          end
        }
        it_behaves_like "sequel bulk updating samples", 0, 2, 2, 2
      end

      context "with dna, rna, cellular material attributes updating samples with dna, rna and cellular material" do
        let(:samples) { [new_sample_with_dna_rna_cellular, new_sample_with_dna_rna_cellular] }
        subject {
          described_class.new(:store => store, :user => user, :application => application) do |a,s|
            a.by = "sanger_sample_id"
            a.updates = {}.tap do |h|
              sanger_sample_ids.each do |uuid|
                h[uuid] = {:dna => {:pre_amplified => true, :extraction_method => "method"},
                           :rna => {:pre_amplified => true, :extraction_method => "method"},
                           :cellular_material => {:lysed => true}}
              end
            end
          end
        }
        it_behaves_like "sequel bulk updating samples", 0, 0, 0, 0
      end

      context "with genotyping attributes updating samples with dna, rna and cellular material" do
        let(:samples) { [new_sample_with_dna_rna_cellular, new_sample_with_dna_rna_cellular] }
        subject {
          described_class.new(:store => store, :user => user, :application => application) do |a,s|
            a.by = "sanger_sample_id"
            a.updates = {}.tap do |h|
              sanger_sample_ids.each do |uuid|
                h[uuid] = {:genotyping => genotyping_parameters} 
              end
            end
          end
        }
        it_behaves_like "sequel bulk updating samples", 0, 0, 0, 0, 2
      end
    end
  end
end
