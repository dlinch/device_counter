require "rails_helper"

RSpec.describe DeviceReading do
  subject { build(:device_reading) }

  describe "validations" do
    context "presence" do
      it { should validate_presence_of(:device_id)}
      it { should validate_presence_of(:timestamp_at) }
      it { should validate_presence_of(:count) }
    end

    # it { should validate_uniqueness_of(:device_id).scoped_to(:timestamp_at) }
    it { should validate_numericality_of(:count).is_greater_than(0).only_integer }
  end

  xdescribe ".latest" do
    pending "Unviable until SQL is available"

    subject { described_class }
    let(:latest_reading) { build(:device_reading) }
    let!(:readings) { build(:device_reading, 7, :random_time, device_id: device_id) }
    let(:device_id) { latest_reading.device_id }

    it "returns latest reading for a given device id" do
      expect(subject.latest(device_id).timestamp_at).to eq latest_reading.timestamp_at
    end
  end

  xdescribe ".total_count_for" do
    pending "Unviable until SQL is available"

    subject { described_class }
    let(:device_id) { SecureRandom.uuid }
    let!(:readings) { create_list(:device_reading, 5, :random_time, device_id: device_id, count: 5) }

    it "returns total count for a given device id" do
      expect(subject.total_count_for(device_id)).to eq 25
    end
  end
end