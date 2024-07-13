class DeviceReadingBulkOrchestrator
  KEY_MAPPINGS = {id: :device_id, timestamp: :timestamp_at}.freeze

  def initialize(store)
    @store = store
  end

  def call(raw_device_storage_params)
    normalized_params = normalize_params(raw_device_storage_params)
    @results = normalized_params.map do |params|
      creator = DeviceReadingCreator.new(@store)
      creator.call(params)
    end

    return [:failure] if full_failure? 
    return [:partial_success] if partial_success?
    [:success]
  end

  def full_success?
    @results.all? { |result| result.first == :success}
  end

  def error_results
    @results.reject { |result| result.first == :success }
  end

  def partial_success?
    !full_failure? && !full_success?
  end

  def full_failure?
    @results.none? { |result| result.first == :success }
  end

  def normalize_params(params)
    params.try(:deep_symbolize_keys!)
    id = params[:id]
    params[:readings].map do |reading|
      reading
        .to_h
        .deep_symbolize_keys
        .merge({id: id})
        .transform_keys(KEY_MAPPINGS)
    end
  end
end
