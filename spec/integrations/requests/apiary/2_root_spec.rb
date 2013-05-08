require "integrations/requests/apiary/spec_helper"
describe "root" do
  include_context "use core context service"
  it "root" do
  # --
  # Root
  # --
  # 
  # The root JSON lists all the resources available through the Lims Support Application and all the actions which can be performed. 
  # A resource responds to all the actions listed under its `actions` elements.
  # Consider this URL and the JSON response like the entry point for S2 Lims Support Application. All the other interactions through the 
  # Support App can be performed browsing this JSON response.

    header('Accept', 'application/json')
    header('Content-Type', 'application/json')

    response = get "/"
    response.status.should == 200
    response.body.should match_json <<-EOD
    {
    "actions": {
        "read": "http://example.org/"
    },
    "samples": {
        "actions": {
            "create": "http://example.org/samples",
            "read": "http://example.org/samples",
            "first": "http://example.org/samples/page=1",
            "last": "http://example.org/samples/page=-1"
        }
    },
    "uuid_resources": {
        "actions": {
            "create": "http://example.org/uuid_resources",
            "read": "http://example.org/uuid_resources",
            "first": "http://example.org/uuid_resources/page=1",
            "last": "http://example.org/uuid_resources/page=-1"
        }
    },
    "bulk_create_samples": {
        "actions": {
            "create": "http://example.org/actions/bulk_create_sample"
        }
    },
    "update_samples": {
        "actions": {
            "create": "http://example.org/actions/update_sample"
        }
    },
    "delete_samples": {
        "actions": {
            "create": "http://example.org/actions/delete_sample"
        }
    },
    "bulk_delete_samples": {
        "actions": {
            "create": "http://example.org/actions/bulk_delete_sample"
        }
    },
    "create_samples": {
        "actions": {
            "create": "http://example.org/actions/create_sample"
        }
    },
    "bulk_update_samples": {
        "actions": {
            "create": "http://example.org/actions/bulk_update_sample"
        }
    },
    "revision": 3
}
    EOD

  end
end
