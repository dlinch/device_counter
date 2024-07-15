class DeviceReading
  include ActiveModel::Model
  include ActiveModel::Attributes
  # include ActiveModel::Validations
  # self.primary_key = [:device_id, :timestamp_at]

  attr_accessor :device_id
  attr_writer :timestamp_at
  # Remove typecast to ensure model validations can do their thing
  attribute :count

  validates :device_id, presence: true
  validates :timestamp_at, presence: true
  validates :count, presence: true, numericality: { only_integer: true, greater_than: 0 }

  def count_key
    "#{device_id}_count"
  end

  def latest_timestamp_key
    "#{device_id}_latest_timestamp"
  end

  def unique_timestamp_key
    "#{device_id}_#{timestamp_at}"
  end

  def timestamp_at
    @timestamp_at.respond_to?(:iso8601) ? @timestamp_at.iso8601 : @timestamp_at
  end

  # Future query options if/when we can move data into disk
  # scope :latest, ->(device_id) { where(device_id: device_id).order(timestamp_at: :desc).limit(1).first }

  # def self.total_count_for(device_id)
  #   where(device_id: device_id).sum(:count)
  # end
end
