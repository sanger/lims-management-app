require 'integrations/spec_helper'
require 'lims-management-app/sample-collection/sample_collection_shared'
require 'lims-management-app/persistence/sequel/spec_helper'
require 'lims-management-app/sample-collection/sample_collection_sequel_persistor'

module Lims::ManagementApp
  describe SampleCollection::SampleCollectionSequelPersistor do
    include_context "use core context service"
    include_context "collection factory"
    include_context "timecop"

    shared_examples_for "modify table" do |table, n|
      it "should modify the #{table} table" do
        expect do
          store.with_session do |session|
            session << collection
          end
        end.to change { db[table.to_sym].count }.by(n)
      end
    end

    context "valid" do
      let(:collection) { new_sample_collection }
      let(:collection_id) { save(collection) }

      it_behaves_like "modify table", :collections, 1
      it_behaves_like "modify table", :collections_samples, 3
      it_behaves_like "modify table", :collection_data_string, 1
      it_behaves_like "modify table", :collection_data_int, 1
      it_behaves_like "modify table", :collection_data_url, 1
      it_behaves_like "modify table", :collection_data_bool, 1
      it_behaves_like "modify table", :collection_data_uuid, 1

      it "should be reloadable" do
        store.with_session do |session|
          c = session.sample_collection[collection_id]
          c.should == session.sample_collection[collection_id]
        end
      end

      it "reloads the samples in the collection" do
        store.with_session do |session|
          c = session.sample_collection[collection_id]
          c.samples.size.should == collection.samples.size
          c.samples.each do |sample|
            sample.should be_a(Sample)
          end
        end
      end

      it "reloads the data in the collection" do
        store.with_session do |session|
          c = session.sample_collection[collection_id]
          c.data.size.should == collection.data.size
          c.data.sort do |a,b|
            a.class.to_s <=> b.class.to_s
          end.zip(collection.data.sort do |a,b|
            a.class.to_s <=> b.class.to_s
          end).each do |data_saved, data|
            data_saved.should be_a(data.class)
            data_saved.key.should == data.key
            data_saved.value.should == data.value
          end
        end
      end
    end
  end
end
