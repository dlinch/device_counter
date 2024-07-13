require "rails_helper"

RSpec.describe "Device Readings", type: :request do
  describe "POST /" do
    let(:params) { {id: SecureRandom.uuid, readings: readings} }
    let(:readings) { [{timestamp: 5.minutes.ago.iso8601, count: 5}, {timestamp: 3.minutes.ago.iso8601, count: 8}]}

    it "creates readings" do
      post "/device_readings", params: params

      expect(response).to be_ok
    end
    
    it "returns failure if the reading is a duplicate"
    it "returns error messages if the reading is invalid"
    it "returns responses for all supplied readings, valid or invalid"
  end

  describe "GET /:id" do
    let(:device_reading) { build(:device_reading) }
    before do
      # put items in store, see if they are properly retrieved 
    end

    it "returns a device's latest timestamp and cumulative count" do
      get "/device_readings/#{device_reading.device_id}"

      expect(response.content_type).to match("application/json;")
      expect(response).to be_ok
      expect(parsed_body).to eq({cumulative_count: 10, latest_timestamp: ''})
    end
  end
end
