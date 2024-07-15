require "rails_helper"

RSpec.describe "Device Readings", type: :request do
  let(:store) { DeviceStorage.instance.connection }

  describe "POST /", parse_json: true do
    let(:params) { {id: SecureRandom.uuid, readings: readings} }
    let(:readings) { [{timestamp: "#{5.minutes.ago.iso8601}", count: "5"}, {timestamp: "#{3.minutes.ago.iso8601}", count: "8"}]}

    it "creates readings" do
      post "/device_readings", params: params

      expect(response).to be_ok
      expect(store).to have_cache_key("#{params[:id]}_count").with_value(13)
      expect(store).to have_cache_key("#{params[:id]}_latest_timestamp").with_timestamp_value(readings.second[:timestamp])
      expect(store).to have_cache_key("#{params[:id]}_#{readings.first[:timestamp]}")
      expect(store).to have_cache_key("#{params[:id]}_#{readings.second[:timestamp]}")
    end

    it "assigns latest timestamp" do
      soonest = "#{1.minute.ago.iso8601}"
      latest = "#{10.minutes.ago.iso8601}"
      post "/device_readings", params: params.merge(readings: [{timestamp: soonest, count: "5"}])

      expect(response).to be_ok
      expect(store).to have_cache_key("#{params[:id]}_count").with_value(5)
      expect(store).to have_cache_key("#{params[:id]}_latest_timestamp").with_timestamp_value(soonest)

      post "/device_readings", params: params.merge(readings: [{timestamp: latest, count: "5"}])
      expect(response).to be_ok
      expect(store).to have_cache_key("#{params[:id]}_count").with_value(10)
      expect(store).to have_cache_key("#{params[:id]}_latest_timestamp").with_timestamp_value(soonest)
    end

    context "duplicate readings" do
      let(:time) { 5.minutes.ago.iso8601 }
      let(:readings) { [{timestamp: time, count: 5}, {timestamp: time, count: 5}, {timestamp: time, count: 5}]}

      it "returns failure if the reading is a duplicate" do
        post "/device_readings", params: params

        expect(response).to be_ok
        expect(store).to have_cache_key("#{params[:id]}_count").with_value(5)
        expect(store).to have_cache_key("#{params[:id]}_latest_timestamp")
        expect(parsed_body).to eq({"errors" => [["error", "duplicate", params[:id]], ["error", "duplicate", params[:id]]]})
      end
    end

    it "returns error messages if the reading is invalid" do
      allow_any_instance_of(DeviceReadingCreator).to receive(:call).and_return([:error, "This is a doozy."])

      post "/device_readings", params: params

      expect(response).not_to be_ok
      expect(store).not_to have_cache_key("#{params[:id]}_count")
      expect(parsed_body).to eq({"errors" => [["error", "This is a doozy."], ["error", "This is a doozy."]]})
    end
  end

  describe "GET /:id", parse_json: true do
    let(:device_reading) { build(:device_reading) }
    let(:time) { 5.minutes.ago.iso8601 }

    before do
      store.write(device_reading.count_key, 10)
      store.write(device_reading.latest_timestamp_key, time)
    end

    it "returns a device's latest timestamp and cumulative count" do
      get "/device_readings/#{device_reading.device_id}"

      expect(response.content_type).to match("application/json;")
      expect(response).to be_ok
      expect(parsed_body).to eq({"cumulative_count" => 10, "latest_timestamp" => time.to_s})
    end
  end
end
