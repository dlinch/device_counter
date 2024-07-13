class DeviceReading < ApplicationRecord
  self.primary_key = [:device_id, :timestamp_at]

  validates :device_id, presence: true, uniqueness: { scope: :timestamp_at }
  validates :timestamp_at, presence: true
  validates :count, presence: true, numericality: { only_integer: true, greater_than: 0 }

  def count_key
    "#{device_id}_count"
  end

  def latest_timestamp_key
    "#{device_id}_latest_timestamp"
  end

  def unique_timestamp_key
    "#{device_id}_#{timestamp_at.iso8601}"
  end

  # Future query options if/when we can move data into disk
  scope :latest, ->(device_id) { where(device_id: device_id).order(timestamp_at: :desc).limit(1).first }

  def self.total_count_for(device_id)
    where(device_id: device_id).sum(:count)
  end
end
