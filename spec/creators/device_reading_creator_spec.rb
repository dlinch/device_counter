require "rails_helper"

RSpec.describe DeviceReadingCreator do
  let(:params) { {device_id: SecureRandom.uuid, timestamp_at: 10.minutes.ago.iso8601, count: 3} }
  let(:store) { DeviceStorage.instance.connection }
  let(:device) { DeviceReading.new(params) }

  subject { described_class.new(store).call(params) }

  describe "#create" do
    it "adds new values to the cache if not present" do
      expect(store).to_not have_cache_key(device.count_key)
      expect(store).to_not have_cache_key(device.latest_timestamp_key)
      expect(store).to_not have_cache_key(device.unique_timestamp_key)

      subject

      expect(store).to \
        have_cache_key(device.count_key).with_value(3)
      expect(store).to \
        have_cache_key(device.latest_timestamp_key).with_value(params[:timestamp_at])
      expect(store).to \
        have_cache_key(device.unique_timestamp_key)
    end

    it "updates the latest timestamp if the new timestamp is later" do
      subject
      expect(store).to have_cache_key(device.latest_timestamp_key).with_value(params[:timestamp_at])

      new_timestamp = 30.seconds.ago.iso8601
      described_class.new(store).call(params.merge(timestamp_at: new_timestamp)) 
      expect(store).to have_cache_key(device.latest_timestamp_key).with_value(new_timestamp)
    end

    it "does not update timestamp if the timestamp is earlier" do
      subject
      expect(store).to have_cache_key(device.latest_timestamp_key).with_value(params[:timestamp_at])

      new_timestamp = 3.hours.ago.iso8601
      described_class.new(store).call(params.merge(timestamp_at: new_timestamp)) 
      expect(store).to have_cache_key(device.latest_timestamp_key).with_value(params[:timestamp_at])
    end

    it "increments count for a device_id" do
      subject
      expect(store).to have_cache_key(device.count_key).with_value(3)

      new_timestamp = 30.seconds.ago.iso8601
      described_class.new(store).call(params.merge(timestamp_at: new_timestamp)) 
      expect(store).to have_cache_key(device.count_key).with_value(6)
    end

    describe "failure" do
      it "returns an error in the result array for a duplicate" do
        result1, result2 = subject, described_class.new(store).call(params)

        expect(result1.first).to eq(:success)
        expect(result1.last).to be_kind_of(DeviceReading)
        expect(result2).to eq([:error, :duplicate])
      end

      context "bad params" do
        let(:params) { {device_id: SecureRandom.uuid, timestamp_at: 10.minutes.ago.iso8601, count: 0} }

        it "returns an error in the result array for bad validation" do
          expect(subject).to eq([:error, "Count must be greater than 0"])
        end
      end

      context "missing params" do
        let(:params) { {device_id: SecureRandom.uuid, count: 1} }
        it "returns an error if a parameter is missing" do
          expect(subject).to eq([:error, "Timestamp at can't be blank"])
        end
      end
    end
  end
end