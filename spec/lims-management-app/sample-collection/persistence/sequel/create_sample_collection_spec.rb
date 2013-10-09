require 'lims-management-app/sample-collection/persistence/sequel/spec_helper'
require 'lims-management-app/sample-collection/sample_collection_shared'
require 'lims-management-app/sample-collection/create_sample_collection'
require 'integrations/spec_helper'

module Lims::ManagementApp
  describe SampleCollection::CreateSampleCollection do
    include_context "sequel store"
    include_context "for application", "create collection"
    include_context "collection factory"
    include_context "sample collection configuration"

    context "with valid parameters" do
      context "when using sample uuids" do
        subject {
          described_class.new(:store => store, :user => user, :application => application) do |a,s|
            a.type = "Study"
            a.data = sample_collection_action_data
            a.sample_uuids = sample_collection_action_sample_uuids
          end
        }

        let!(:sample_uuids) {
          sample_collection_action_sample_uuids.tap do |uuids|
            uuids.each do |uuid|
              store.with_session do |session|
                set_uuid(session, new_common_sample, uuid)
              end
            end
          end
        }

        it_behaves_like "changing the table", :collections, 1 
        it_behaves_like "changing the table", :collections_samples, 3
        it_behaves_like "changing the table", :collection_data_string, 1
        it_behaves_like "changing the table", :collection_data_int, 1
        it_behaves_like "changing the table", :collection_data_url, 1
        it_behaves_like "changing the table", :collection_data_bool, 2
        it_behaves_like "changing the table", :collection_data_uuid, 1
        it_behaves_like "changing the table", :samples, 0
      end

      context "when creating new samples" do
        subject {
          described_class.new(:store => store, :user => user, :application => application) do |a,s|
            a.type = "Study"
            a.data = sample_collection_action_data
            a.samples = samples
          end
        }

        context "common samples" do
          let(:samples) { common_sample_parameters.merge(:quantity => 3, :sanger_sample_id_core => "test") } 
          it_behaves_like "changing the table", :collections, 1 
          it_behaves_like "changing the table", :collections_samples, 3
          it_behaves_like "changing the table", :collection_data_string, 1
          it_behaves_like "changing the table", :collection_data_int, 1
          it_behaves_like "changing the table", :collection_data_url, 1
          it_behaves_like "changing the table", :collection_data_bool, 2
          it_behaves_like "changing the table", :collection_data_uuid, 1
          it_behaves_like "changing the table", :uuid_resources, 4
          it_behaves_like "changing the table", :samples, 3
          it_behaves_like "changing the table", :dna, 0
          it_behaves_like "changing the table", :rna, 0
          it_behaves_like "changing the table", :cellular_material, 0
          it_behaves_like "changing the table", :genotyping, 0
        end

        context "samples with dna" do
          let(:samples) { common_sample_parameters.merge(:dna => dna_parameters, :quantity => 3, :sanger_sample_id_core => "test") } 
          it_behaves_like "changing the table", :samples, 3
          it_behaves_like "changing the table", :dna, 3
          it_behaves_like "changing the table", :rna, 0
          it_behaves_like "changing the table", :cellular_material, 0
          it_behaves_like "changing the table", :genotyping, 0
        end

        context "samples with rna and genotyping" do
          let(:samples) { common_sample_parameters.merge(:rna => rna_parameters, :genotyping => genotyping_parameters, :quantity => 3, :sanger_sample_id_core => "test") } 
          it_behaves_like "changing the table", :samples, 3
          it_behaves_like "changing the table", :dna, 0
          it_behaves_like "changing the table", :rna, 3
          it_behaves_like "changing the table", :cellular_material, 0
          it_behaves_like "changing the table", :genotyping, 3
        end

        context "samples with everything" do
          let(:samples) { full_sample_parameters.merge(:quantity => 3, :sanger_sample_id_core => "test") } 
          it_behaves_like "changing the table", :samples, 3
          it_behaves_like "changing the table", :dna, 3
          it_behaves_like "changing the table", :rna, 3
          it_behaves_like "changing the table", :cellular_material, 3
          it_behaves_like "changing the table", :genotyping, 3
        end
      end
    end


    context "with invalid parameters" do

      context "with invalid sample uuids" do
        subject {
          described_class.new(:store => store, :user => user, :application => application) do |a,s|
            a.type = "Study"
            a.sample_uuids = sample_collection_action_sample_uuids
          end
        }

        it "raises an exception" do
          expect do
            subject.call
          end.to raise_error(SampleCollection::SampleNotFound)
        end
      end

      context "with unknown sample taxon_id" do
        subject {
          described_class.new(:store => store, :user => user, :application => application) do |a,s|
            a.type = "Study"
            a.samples = full_sample_parameters.merge({:quantity => 1, :sanger_sample_id_core => "s2", :taxon_id => 9600})
          end
        }

        it "raises en error" do
          expect do
            subject.call
          end.to raise_error(Sample::UnknownTaxonIdError)
        end
      end

      context "with sample taxon_id and scientific name which don't match" do
        subject {
          described_class.new(:store => store, :user => user, :application => application) do |a,s|
            a.type = "Study"
            a.samples = full_sample_parameters.merge({:quantity => 1, :sanger_sample_id_core => "s2", :taxon_id => 9606, :scientific_name => "dummy"})
          end
        }

        it "raises an error" do
          expect do
            subject.call
          end.to raise_error(Sample::NameTaxonIdMismatchError)
        end
      end
    end
  end
end
