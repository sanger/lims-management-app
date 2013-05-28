require "integrations/requests/apiary/11_sample_resource/spec_helper"
describe "list_actions_for_a_sample_resource", :sample => true do
  include_context "use core context service"
  it "list_actions_for_a_sample_resource" do
  # **List actions for a barcode resource.**
  # 
  # * `create` creates a new barcode via HTTP POST request
  # * `read` currently returns the list of actions for a barcode resource via HTTP GET request
  # * `first` lists the first barcode resources in a page browsing system
  # * `last` lists the last barcode resources in a page browsing system

    header('Accept', 'application/json')
    header('Content-Type', 'application/json')

    response = get "/samples"
    response.status.should == 200
    response.body.should match_json <<-EOD
    {
    "samples": {
        "actions": {
            "create": "http://example.org/samples",
            "read": "http://example.org/samples",
            "first": "http://example.org/samples/page=1",
            "last": "http://example.org/samples/page=-1"
        }
    }
}
    EOD

  end
end
