require 'lims-management-app/persistence/sequel/spec_helper'
require 'integration/spec_helper'
require 'lims-management-app/sample/sample_sequel_persistor'

module Lims::ManagementApp
  describe Sample::SampleSequelPersistor do
    include_context "use core context service"

    let(:parameters) { {:hmdmc_number => "test", :supplier_sample_name => "test", :common_name => "test",
    :ebi_accession_number => "test", :sample_source => "test", :mother => "test", :father => "test",
    :sibling => "test", :gc_content => "test", :public_name => "test", :cohort => "test", 
    :storage_conditions => "test", :taxon_id => 1, :gender => "male", :sanger_sample_id => "test",
    :sample_type => "RNA", :volume => 1, :date_of_sample_collection => Time.now, 
    :is_sample_a_control => true, :is_re_submitted_sample => false} }

    let(:sample) { Sample.new(parameters) }

    context "when created within a session" do
      it "should modify the sample table" do
        expect do 
          store.with_session do |session|
            session << sample
          end
        end.to change { db[:samples].count }.by(1)
      end
    end
  end
end
