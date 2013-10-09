require "integrations/requests/apiary/12_sample_collection_resource/spec_helper"
describe "list_actions_for_a_sample_collection_resource", :sample_collection => true do
  include_context "use core context service"
  it "list_actions_for_a_sample_collection_resource" do

    header('Accept', 'application/json')
    header('Content-Type', 'application/json')

    response = get "/sample_collections"
    response.status.should == 200
    response.body.should match_json <<-EOD
    {
    "sample_collections": {
        "actions": {
            "create": "http://example.org/sample_collections",
            "read": "http://example.org/sample_collections",
            "first": "http://example.org/sample_collections/page=1",
            "last": "http://example.org/sample_collections/page=-1"
        }
    }
}
    EOD

  end
end
