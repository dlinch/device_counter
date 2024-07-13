class DeviceReadingsController < ApplicationController
  def create
    result = DeviceReadingBulkOrchestrator.new(store).call(device_storage_params)

    case result
    in [:failure]
      render json: {errors: result.error_results}, status: 422
    in [:partial_success]
      render json: {errors: result.error_results}, status: 200
    else
      head :ok
    end
  end

  def show
    render json: read_results
  end

  private

  def device_storage_params
    params.permit(:id, readings: [:timestamp_at, :count])
  end

  def read_keys(id)
    device_reading = DeviceReading.new(device_id: id)

    [device_reading.count_key, device_reading.latest_timestamp_key]
  end

  def read_results
    keys = read_keys(params[:id])
    results = store.read_multi(*keys)

    {cumulative_count: results[keys.first], latest_timestamp: results[key.last]}
  end
end
