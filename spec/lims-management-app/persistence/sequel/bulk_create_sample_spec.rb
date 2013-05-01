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
        it "modify the samples table" do
          expect do
            subject.call
          end.to change { db[:samples].count }.by(quantity)
        end
      end

      context "samples with dna" do
        it "modify the samples table" do
          expect do
            subject.call
          end.to change { db[:samples].count }.by(quantity)
        end

        it "modify the dna table" do
          expect do
            subject.call
          end.to change { db[:dna].count }.by(quantity)
        end
      end

      context "samples with dna, rna and cellular material" do
        it "modify the samples table" do
          expect do
            subject.call
          end.to change { db[:samples].count }.by(quantity)
        end

        it "modify the dna table" do
          expect do
            subject.call
          end.to change { db[:dna].count }.by(quantity)
        end

        it "modify the rna table" do
          expect do
            subject.call
          end.to change { db[:rna].count }.by(quantity)
        end

        it "modify the cellular_material table" do
          expect do
            subject.call
          end.to change { db[:cellular_material].count }.by(quantity)
        end
      end
    end


    context "samples bulk creation" do
      let(:quantity) { 3 }

      subject {
        described_class.new(:store => store, :user => user, :application => application) do |a,s|
          full_sample_parameters.each do |k,v|
            a.send("#{k}=", v)
          end
          a.quantity = quantity
        end
      }

      it_behaves_like "sequel bulk creating samples"
    end
  end
end
