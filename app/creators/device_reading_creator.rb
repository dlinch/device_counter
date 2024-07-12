class DeviceReadingCreator < ApplicationCreator
  delegate :count_key, :latest_timestamp_key, :unique_timestamp_key, :valid?, to: :record

  def call(params)
    @record = DeviceReading.new(params)

    return [:error, formatted_errors] if invalid?
    return [:error, :duplicate] if is_duplicate?

    write_timestamp
    update_count
    conditionally_change_latest_timestamp
  end

  private

  def conditionally_change_latest_timestamp
    latest_timestamp = fetch(latest_timestamp_key) { record.timestamp_at }

    if record.timestamp_at > latest_timestamp.to_time
      write(latest_timestamp_key, record.timestamp_at)
    end
  end

  def is_duplicate?
    exist?(unique_timestamp_key)
  end

  def update_count
    increment(count_key, record.count)
  end

  def write_timestamp
    write(unique_timestamp_key, true)
  end
end