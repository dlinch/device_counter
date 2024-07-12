FactoryBot.define do
  factory(:device_reading) do
    count { [*1..25].sample }
    device_id { SecureRandom.uuid }
    timestamp_at { Time.now }

    trait :random_time do
      timestamp_at { rand(1.hour.ago..10.minutes.ago) }
    end
  end
end
