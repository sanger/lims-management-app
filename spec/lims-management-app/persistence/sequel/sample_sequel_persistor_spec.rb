require 'lims-management-app/persistence/sequel/spec_helper'
require 'lims-management-app/sample/sample_sequel_persistor'
require 'integrations/spec_helper'

module Lims::ManagementApp
  shared_examples "a sample" do
    before do
      Sample::SangerSampleID.stub!(:generate) do
        "S2-test-ID"
      end
    end

    let(:sample_id) { save(sample) }
    let(:expected_sanger_sample_id) { "S2-test-ID" }

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

    it "should generate a sanger sample id on save" do
      store.with_session do |session|
        session.sample[sample_id].sanger_sample_id.should == expected_sanger_sample_id
      end
    end
  end


  describe Sample::SampleSequelPersistor do
    include_context "use core context service"

    let(:parameters) { {:hmdmc_number => "test", :supplier_sample_name => "test", :common_name => "test",
                        :ebi_accession_number => "test", :sample_source => "test", :mother => "test", :father => "test",
                        :sibling => "test", :gc_content => "test", :public_name => "test", :cohort => "test", 
                        :storage_conditions => "test", :taxon_id => 1, :gender => "male", 
                        :sample_type => "RNA", :volume => 1, :date_of_sample_collection => Time.now, 
                        :is_sample_a_control => true, :is_re_submitted_sample => false} }
    let(:cellular_material_parameters) { {:lysed => true} }
    let(:dna_rna_parameters) { {:pre_amplified => true, :date_of_sample_extraction => Time.now,
                                :extraction_method => "method", :concentration => 10, :sample_purified => false,
                                :concentration_determined_by_which_method => "method"} }

    let(:dna) { Sample::Dna.new(dna_rna_parameters) }
    let(:rna) { Sample::Rna.new(dna_rna_parameters) }
    let(:cellular_material) { Sample::CellularMaterial.new(cellular_material_parameters) }


    context "common sample" do
      let(:sample) { Sample.new(parameters).generate_sanger_sample_id } 
      it_behaves_like "a sample"
    end


    context "sample with dna" do
      let(:sample) do
        s = Sample.new(parameters).generate_sanger_sample_id 
        s.dna = dna
        s
      end
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
      let(:sample) do
        s = Sample.new(parameters).generate_sanger_sample_id 
        s.rna = rna
        s
      end
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
      let(:sample) do
        s = Sample.new(parameters).generate_sanger_sample_id
        s.cellular_material = cellular_material
        s
      end
      it_behaves_like "a sample"

      it "should modify the cellular material table" do
        expect do
          store.with_session do |session|
            session << sample
          end
        end.to change { db[:cellular_material].count }.by(1)
      end
    end


    context "sample with dna, rna, cellular material" do
      let(:sample) do
        s = Sample.new(parameters).generate_sanger_sample_id
        s.dna = dna
        s.rna = rna
        s.cellular_material = cellular_material
        s
      end
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
    end
  end
end
