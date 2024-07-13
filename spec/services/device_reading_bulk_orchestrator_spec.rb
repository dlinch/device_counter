require "rails_helper"

RSpec.describe DeviceReadingBulkOrchestrator do
  subject { described_class.new(DeviceStorage.instance.connection) }

  describe "#call" do
    describe "success" do
      let(:params) do
        {
          "id" => SecureRandom.uuid,
          "readings" => [
            {"timestamp" => Time.now.iso8601, "count": 10},
            {"timestamp" => 5.minutes.ago.iso8601, "count": 10},
          ]
        }
      end

      it "returns a result" do
        expect(subject.call(params)).to eq [:success]
      end
    end

    describe "partial_success" do
      let(:params) do
        timestamp = 5.minutes.ago
        {
          "id" => SecureRandom.uuid,
          "readings" => [
            {"timestamp" => timestamp, "count": -1},
            {"timestamp" => timestamp, "count": 10},
          ]
        }
      end

      it "returns a result" do
        expect(subject.call(params)).to eq [:partial_success]
      end
    end

    describe "failure" do
      let(:params) do
        {
          "id" => SecureRandom.uuid,
          "readings" => [
            {"timestamp" => 5.minutes.ago, "count": -1},
            {"timestamp" => 3.minutes.ago, "count": -10},
          ]
        }
      end

      it "returns a result" do
        expect(subject.call(params)).to eq [:failure]
      end
    end
  end
end
