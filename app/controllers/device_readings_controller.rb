class DeviceReadingsController < ApplicationController
  def create
    creator = DeviceReadingCreator.new(store)
    case creator.call(device_storage_params)
    in [:error, :duplicate]
      render json: {}, status: 422
    in [:error, String => errors]
      render json: {errors: errors}
    else
      head :ok
    end
  end

  def show
    render json: read_results
  end

  private

  def device_storage_params
    params.permit(:device_id, :timestamp_at, :count)
  end

  def read_keys(id)
    device_reading = DeviceReading.new(id)

    [device_reading.count_key, device_reading.latest_timestamp_key]
  end

  def read_results
    keys = read_keys(params[:id])
    results = store.read_multi(*keys)

    {cumulative_count: results[keys.first], latest_timestamp: results[key.last]}
  end
end
