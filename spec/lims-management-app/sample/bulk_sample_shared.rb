module Lims::ManagementApp
  shared_examples "creates an array of sample objects" do
    it do
      samples = result[:samples]
      samples.should be_a(Array)
      samples.size.should == 2
      samples.each do |sample|
        sample.should be_a(Sample)
      end
    end
  end

  shared_context "create parameters" do
    include_context "sample factory"
    include_context "for application", "sample copying"
    include_context "sequel store"
    let(:parameters) { 
      {
        :store => store, 
        :user => user, 
        :application => application,
        :sample_uuids => [mock(:sample_uuid1), mock(:sample_uuid2)],
        :sanger_sample_ids => [mock(:id1), mock(:id2)]
      }
    }
  end

  shared_context "invalid action" do
    it "requires sample uuids or sanger sample ids" do
      described_class.new(parameters - [:sample_uuids, :sanger_sample_ids]).valid?.should == false
    end
  end

  shared_context "valid action" do |bulk_action, sample_uuid_not_found_error, sanger_sample_id_not_found_error|
    let(:result) { subject.call }

    context "with sample uuids" do
      subject {
        described_class.new(:store => store, :user => user, :application => application) do |a,s|
          a.sample_uuids = sample_uuids
        end
      }

      it "has valid parameters" do
        described_class.new(parameters - [:sanger_sample_ids]).valid?.should == true
      end

      context "with valid sample uuids" do
        let!(:sample_uuids) do
          [new_common_sample, new_common_sample].map do |sample|
            store.with_session do |session|
              session << sample
              uuid = session.uuid_for!(sample)
              lambda { uuid }
            end.call
          end
        end
        it_behaves_like bulk_action
      end

      context "with invalid sample uuids" do
        let!(:sample_uuids) do
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
          }.to raise_error(sample_uuid_not_found_error)
        end
      end
    end

    context "with sanger sample ids" do
      subject {
        described_class.new(:store => store, :user => user, :application => application) do |a,s|
          a.sanger_sample_ids = sanger_sample_ids
        end
      }

      it "has valid parameters" do
        described_class.new(parameters - [:sample_uuids]).valid?.should == true
      end

      context "with valid sanger sample ids" do
        let!(:sanger_sample_ids) do
          [new_common_sample, new_common_sample].each_with_index.map do |sample, i|
            store.with_session do |session|
              session << sample
              sample.sanger_sample_id = "s2-#{i}" 
              lambda { sample.sanger_sample_id }
            end.call
          end
        end
        it_behaves_like bulk_action
      end

      context "with invalid sanger sample ids" do
        let!(:sanger_sample_ids) do
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
          }.to raise_error(sanger_sample_id_not_found_error)
        end
      end
    end
  end
end
