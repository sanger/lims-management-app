require 'lims-management-app/persistence/sequel/spec_helper'
require 'lims-management-app/sample/sample_sequel_persistor'
require 'lims-management-app/sample/sample_shared'
require 'integrations/spec_helper'

module Lims::ManagementApp
  shared_examples "a sample" do
    let(:sample_id) { save(sample) }
    let(:expected_sanger_sample_id) { "s2-1" }

    it "should modify the sample table" do
      expect do 
        store.with_session do |session|
          session << sample
        end
      end.to change { db[:samples].count }.by(1)
    end

    it "should be reloadable" do
      store.with_session do |session|
        sample = session.sample[sample_id]
        sample.should == session.sample[sample_id]
      end
    end
  end


  describe Sample::SampleSequelPersistor do
    include_context "use core context service"
    include_context "sample factory"

    context "invalid" do
      context "with an unknown taxon id" do
        let(:sample) { Sample.new(common_sample_parameters.merge(:taxon_id => 9607)) }            
        it "raises an exception" do
          expect do
            save(sample)
          end.to raise_error(Sample::UnknownTaxonIdError)
        end
      end

      context "with a name which does not match a taxon id" do
        let(:sample) { Sample.new(common_sample_parameters.merge({:taxon_id => 9606, :scientific_name => "dummy"})) }
        it "raises an exception" do
          expect do
            save(sample)
          end.to raise_error(Sample::NameTaxonIdMismatchError)
        end
      end
    end

    context "valid" do
      context "common sample", :focus => true do
        let(:sample) { new_common_sample } 
        it_behaves_like "a sample"
      end

      context "sample with dna" do
        let(:sample) { new_sample_with_dna } 
        it_behaves_like "a sample"

        it "should modify the dna table" do
          expect do
            store.with_session do |session|
              session << sample
            end
          end.to change { db[:dna].count }.by(1)
        end
      end

      context "sample with rna" do
        let(:sample) { new_sample_with_rna } 
        it_behaves_like "a sample"

        it "should modify the rna table" do
          expect do
            store.with_session do |session|
              session << sample
            end
          end.to change { db[:rna].count }.by(1)
        end
      end

      context "sample with cellular material" do
        let(:sample) { new_sample_with_cellular_material } 
        it_behaves_like "a sample"

        it "should modify the cellular material table" do
          expect do
            store.with_session do |session|
              session << sample
            end
          end.to change { db[:cellular_material].count }.by(1)
        end
      end

      context "sample with genotyping" do
        let(:sample) { new_sample_with_genotyping } 
        it_behaves_like "a sample"

        it "should modify the genotyping table" do
          expect do
            store.with_session do |session|
              session << sample
            end
          end.to change { db[:genotyping].count }.by(1)
        end
      end

      context "sample with everything" do
        let(:sample) { new_full_sample } 
        it_behaves_like "a sample"

        it "should modify the dna table" do
          expect do
            store.with_session do |session|
              session << sample
            end
          end.to change { db[:dna].count }.by(1)
        end

        it "should modify the rna table" do
          expect do
            store.with_session do |session|
              session << sample
            end
          end.to change { db[:rna].count }.by(1)
        end

        it "should modify the cellular material table" do
          expect do
            store.with_session do |session|
              session << sample
            end
          end.to change { db[:cellular_material].count }.by(1)
        end

        it "should modify the genotyping table" do
          expect do
            store.with_session do |session|
              session << sample
            end
          end.to change { db[:genotyping].count }.by(1)
        end
      end
    end
  end
end
