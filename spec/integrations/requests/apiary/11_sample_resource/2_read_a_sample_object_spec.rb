require "integrations/requests/apiary/11_sample_resource/spec_helper"
describe "read_a_sample_object", :sample => true do
  include_context "use core context service"
  it "read_a_sample_object" do
  # **Create a barcode for an asset.**
  # 
  # * `labware` the specific labware the barcode relates to (tube, plate etc..)
  # * `role` the role of the labware (like 'stock')
  # * `contents` the type of the aliquot the labware contains (DNA, RNA etc...)
    # This is class is generating a fake barcode
    # We will use it when we are generating a new sanger barcode.
    module Lims::SupportApp
        class FakeBarcode
            def self.new_fake_barcode
                "1233334"
            end
        end
    end

    header('Accept', 'application/json')
    header('Content-Type', 'application/json')

    response = post "/barcodes", <<-EOD
    {
    "barcode": {
        "labware": "tube",
        "role": "stock",
        "contents": "DNA"
    }
}
    EOD
    response.status.should == 200
    response.body.should match_json <<-EOD
    {
    "barcode": {
        "actions": {
            "read": "http://example.org/11111111-2222-3333-4444-555555555555",
            "update": "http://example.org/11111111-2222-3333-4444-555555555555",
            "delete": "http://example.org/11111111-2222-3333-4444-555555555555",
            "create": "http://example.org/11111111-2222-3333-4444-555555555555"
        },
        "uuid": "11111111-2222-3333-4444-555555555555",
        "ean13": "2741233334859",
        "sanger": {
            "prefix": "JD",
            "number": "1233334",
            "suffix": "U"
        }
    }
}
    EOD

  end
end
