RSpec::Matchers.define :have_cache_key do |cache_key|
  description { "have a cache key" }
  failure_message do
    case [@key_exists, @value, @timestamp_value]
    in [false, nil, nil]
      "Provided store does not have the key: '#{cache_key}' defined."
    in [true, Time, nil], [true, nil, Time], [true, String, nil]
      "Provided store have the key: '#{cache_key}' defined, but the value is #{@key_value} instead of: #{@value || @timestamp_value}"
    end
  end

  # Need more in depth here
  failure_message_when_negated { "Provided store has the key: '#{cache_key} defined"}

  chain :with_value do |value|
    @value = value
  end

  chain :with_timestamp_value do |timestamp_value|
    @timestamp_value = timestamp_value
  end

  match do |store|
    @cache_key = cache_key
    if @value.present?
      match_with_value
    elsif @timestamp_value.present?
      match_with_timestamp_value
    else
      key_exists?
    end
  end

  def key_exists?
    @key_exists = store.exist?(@cache_key)
  end

  def match_with_timestamp_value
    key_exists? && @timestamp_value.to_time&.iso8601 == store.read(@cache_key)&.to_time&.iso8601
  end

  def match_with_value
    key_exists? && @value == store.read(@cache_key)
  end
end

RSpec::Matchers.define_negated_matcher :not_have_cache_key, :have_cache_key

RSpec::Matchers.define :have_successful_outcome do
  description { "have a successful outcome" }
  failure_message { "Expect result to be successful, but was instead a #{result.first} with message #{result.last}" }
  failure_message_when_negated { "Expected result to be a failure, but instead was a success." }

  chain :with_message do |value|
    @value = value
  end
   
  match do |result|
    result.first == :success &&
      (@value.nil? || result.second == @value)
  end
end