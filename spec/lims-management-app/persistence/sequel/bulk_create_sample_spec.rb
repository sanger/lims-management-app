require 'lims-management-app/persistence/sequel/spec_helper'
require 'lims-management-app/sample/bulk_create_sample'
require 'lims-management-app/sample/sample_shared'
require 'lims-management-app/spec_helper'
require 'integrations/spec_helper'

module Lims::ManagementApp
  describe Sample::BulkCreateSample do
    include_context "sample factory"
    include_context "for application", "bulk create"
    include_context "sequel store"

    shared_examples_for "sequel bulk creating samples" do
      context "common samples" do
        let(:parameters) { common_sample_parameters }
        it_behaves_like "changing the table", :samples, 3
        it_behaves_like "changing the table", :dna, 0
        it_behaves_like "changing the table", :rna, 0
        it_behaves_like "changing the table", :cellular_material, 0
        it_behaves_like "changing the table", :genotyping, 0
      end

      context "samples with dna" do
        let(:parameters) { common_sample_parameters.merge(:dna => dna_parameters) } 
        it_behaves_like "changing the table", :samples, 3
        it_behaves_like "changing the table", :dna, 3
        it_behaves_like "changing the table", :rna, 0
        it_behaves_like "changing the table", :cellular_material, 0
        it_behaves_like "changing the table", :genotyping, 0
      end

      context "samples with rna and genotyping" do
        let(:parameters) { common_sample_parameters.merge({:rna => rna_parameters, :genotyping => genotyping_parameters}) }
        it_behaves_like "changing the table", :samples, 3
        it_behaves_like "changing the table", :dna, 0
        it_behaves_like "changing the table", :rna, 3
        it_behaves_like "changing the table", :cellular_material, 0
        it_behaves_like "changing the table", :genotyping, 3
      end

      context "samples with everything" do
        let(:parameters) { full_sample_parameters } 
        it_behaves_like "changing the table", :samples, 3
        it_behaves_like "changing the table", :dna, 3
        it_behaves_like "changing the table", :rna, 3
        it_behaves_like "changing the table", :cellular_material, 3
        it_behaves_like "changing the table", :genotyping, 3
      end

      context "samples with unknown taxon_id" do
        let(:parameters) { full_sample_parameters.merge({:taxon_id => 9600}) }
        it "raises en error" do
          expect do
            subject.call
          end.to raise_error(Sample::UnknownTaxonIdError)
        end
      end

      context "samples with taxon_id and scientific name which don't match", :focus => true do
        let(:parameters) { full_sample_parameters.merge({:taxon_id => 9606, :scientific_name => "dummy"}) }
        it "raises en error" do
          expect do
            subject.call
          end.to raise_error(Sample::NameTaxonIdMismatchError)
        end
      end
    end

    context "samples bulk creation" do
      let(:quantity) { 3 }

      subject {
        described_class.new(:store => store, :user => user, :application => application) do |a,s|
          parameters.each do |k,v|
            a.send("#{k}=", v)
          end
          a.quantity = quantity
        end
      }

      it_behaves_like "sequel bulk creating samples"
    end
  end
end
