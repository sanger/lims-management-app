require 'lims-management-app/sample-collection/sample_collection_shared'
require 'integrations/spec_helper'

module Lims::ManagementApp
  shared_context "collection sequel factory" do
    include_context "collection factory"

    def new_sequel_sample_collection(collection_uuid, sample_uuids)
      new_sequel_samples(sample_uuids)

      store.with_session do |session|
        samples = {:samples => sample_uuids.map { |uuid| session[uuid] }}
        collection = SampleCollection.new(sample_collection_parameters(samples))
        set_uuid(session, collection, collection_uuid)
      end
    end

    def new_sequel_samples(uuids)
      store.with_session do |session|
        uuids.each do |uuid|
          sample = new_common_sample
          sample.sanger_sample_id = new_sanger_sample_id
          set_uuid(session, sample, uuid)
        end
      end
    end

    def new_sanger_sample_id
      @sanger_sample_id ||= 0
      @sanger_sample_id += 1
      "sanger_sample_id_#{@sanger_sample_id}"
    end
  end
end
