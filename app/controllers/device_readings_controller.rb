class DeviceReadingsController < ApplicationController
  before_action :return_if_prod, only: :index

  def create
    orchestrator = DeviceReadingBulkOrchestrator.new(store)

    result = orchestrator.call(device_storage_params)
    case result
    in [:failure]
      render json: {errors: orchestrator.error_results}, status: 422
    in [:partial_success]
      render json: {errors: orchestrator.error_results}, status: 200
    else
      head :ok
    end
  end

  def show
    render json: read_results
  end

  def index
    render json: store.instance_variable_get(:@data)
  end

  private

  def device_storage_params
    params.permit(:id, readings: [:timestamp, :count])
  end

  def read_keys(id)
    device_reading = DeviceReading.new(device_id: id)

    [device_reading.count_key, device_reading.latest_timestamp_key]
  end

  def read_results
    keys = read_keys(params[:id])
    results = store.read_multi(*keys)

    {cumulative_count: results[keys.first], latest_timestamp: results[keys.last]}
  end

end
