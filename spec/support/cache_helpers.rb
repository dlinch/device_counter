RSpec::Matchers.define :have_cache_key do |cache_key|
  description { "have a cache key" }
  failure_message { "Provided store does not have the key: '#{cache_key}' defined"}
  failure_message_when_negated { "Provided store has the key: '#{cache_key} defined"}

  chain :with_value do |value|
    @value = value
  end

  match do |store|
    store.exist?(cache_key) &&
      (@value.nil? || store.read(cache_key) == @value)
  end
end

RSpec::Matchers.define_negated_matcher :not_have_cache_key, :have_cache_key
