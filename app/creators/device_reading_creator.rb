class DeviceReadingCreator < ApplicationCreator
  delegate :count_key, :latest_timestamp_key, :unique_timestamp_key, to: :record

  def call(params)
    @record = DeviceReading.new(params)

    return [:error, formatted_errors] if invalid?
    return [:error, :duplicate, params[:device_id]] if is_duplicate?

    write_timestamp
    update_count
    conditionally_change_latest_timestamp

    [:success, record]
  end

  private

  def conditionally_change_latest_timestamp
    latest_timestamp = fetch(latest_timestamp_key) { record.timestamp_at }

    if record.timestamp_at.to_time.iso8601 > latest_timestamp.to_time.to_time.iso8601
      write(latest_timestamp_key, record.timestamp_at)
    end
  end

  def is_duplicate?
    exist?(unique_timestamp_key)
  end

  def update_count
    # Increment sets the key if it does not exist
    increment(count_key, record.count.to_i)
  end

  def write_timestamp
    write(unique_timestamp_key, true)
  end
end