require 'lims-management-app/sample/bulk_update_sample'
require 'lims-management-app/sample/sample_shared'
require 'lims-management-app/spec_helper'
require 'integrations/spec_helper'

module Lims::ManagementApp
  describe Sample::BulkUpdateSample do
    shared_examples_for "bulk updating samples" do
      it_behaves_like "an action"

      it "updates sample objects" do
        samples = result[:samples]
        samples.should be_a(Array)
        samples.size.should == 2
        samples.each do |sample|
          sample.should be_a(Sample)
          sample.state.should == state
          updated_parameters.each do |uuid, parameters|
            parameters.each do |k,v|
              v = DateTime.parse(v) if k.to_s =~ /date/
              if [:dna, :rna, :cellular_material, :genotyping].include?(k)
                v.each do |k2,v2|
                  sample.send(k).send(k2).to_s.should == v2.to_s
                end
              else
                sample.send(k).to_s.should == v.to_s
              end
            end
          end
        end
      end
    end

    include_context "sample factory"
    include_context "for application", "sample creation"
    include_context "sequel store"
    let(:parameters) { 
      {
        :store => store, 
        :user => user, 
        :application => application,
        :by => "sanger_sample_id",
        :updates => {mock(:uuid1) => {}}
      }
    }

    context "invalid action" do
      it "requires a valid by attribute" do
        described_class.new(parameters.merge({:by => "dummy"})).valid?.should == false
      end

      it "requires a updates hash" do
        described_class.new(parameters - [:updates]).valid?.should == false
      end

      it "requires a correct gender" do
        described_class.new(parameters[:updates].merge({'dummy_uuid' => {:gender => 'dummy'}})).valid?.should == false
      end

      it "requires a correct sample type" do
        described_class.new(parameters[:updates].merge({'dummy_uuid' => {:sample_type => 'dummy'}})).valid?.should == false
      end

      it "requires that taxon_id and human sample match if taxon_id is a human one", :focus => true do
        wrong_parameters = parameters.tap do |p|
          p[:updates]['dummy_uuid'] = {:taxon_id => 9606, :gender => 'not applicable'}
        end
        described_class.new(wrong_parameters).valid?.should == false
      end

      it "requires a correct state" do
        described_class.new(parameters[:updates].merge({'dummy_uuid' => {:state => 'dummy'}})).valid?.should == false
      end
    end


    context "valid action" do
      let(:result) { subject.call }
      let(:state) { "published" }
      let(:updated_parameters) do
        {}.tap do |updates|
          sample_refs.each do |uuid|
            updates[uuid] = update_parameters(full_sample_parameters).merge({:state => state})
          end
        end
      end

      context "with sample uuids" do
       subject {
          described_class.new(:store => store, :user => user, :application => application) do |a,s|
            a.updates = updated_parameters
          end
        }

        it "has valid parameters" do
          described_class.new(parameters - [:by]).valid?.should == true
        end

        context "with valid sample uuids" do
          let!(:sample_refs) do
            [new_common_sample, new_common_sample].map do |sample|
              store.with_session do |session|
                session << sample
                uuid = session.uuid_for!(sample)
                lambda { uuid }
              end.call
            end
          end
          it_behaves_like "bulk updating samples"
        end

        context "with invalid sample uuids" do
          let!(:sample_refs) do
            uuid1 = store.with_session do |session|
              sample = new_common_sample
              session << sample
              uuid = session.uuid_for!(sample)
              lambda { uuid }
            end.call
            [uuid1, "dummy_uuid"]
          end

          it "raises an exception" do
            expect {
              subject.call
            }.to raise_error(Sample::BulkUpdateSample::SampleUuidNotFound)
          end
        end
      end


      context "with sanger sample ids" do
        subject {
          described_class.new(:store => store, :user => user, :application => application) do |a,s|
            a.by = "sanger_sample_id"
            a.updates = updated_parameters
          end
        }

        it "has valid parameters" do
          described_class.new(parameters).valid?.should == true
        end

        context "with valid sanger sample ids" do
          let!(:sample_refs) do
            [new_common_sample, new_common_sample].each_with_index.map do |sample, i|
              store.with_session do |session|
                session << sample
                sample.sanger_sample_id = "s2-#{i}"
                lambda { sample.sanger_sample_id }
              end.call
            end
          end
          it_behaves_like "bulk updating samples"
        end

        context "with invalid sanger sample ids" do
          let!(:sample_refs) do
            id1 = store.with_session do |session|
              sample = new_common_sample
              session << sample
              sample.sanger_sample_id = "s2-1"
              lambda { sample.sanger_sample_id }
            end.call
            [id1, "dummy_id"]
          end

          it "raises an exception" do
            expect {
              subject.call
            }.to raise_error(Sample::BulkUpdateSample::SangerSampleIdNotFound)
          end
        end
      end
    end
  end
end
