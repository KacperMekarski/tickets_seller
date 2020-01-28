# frozen_string_literal: true

FactoryBot.define do
  factory :event do
    name { Faker::Music.band + ' concert' }
    location { Faker::Address.full_address }
    happens_at { Faker::Time.between(from: DateTime.now + 100.days, to: DateTime.now + 365.days, format: :short) }
    ticket_price { Faker::Number.within(range: 1..100_000) }
    tickets_amount { Faker::Number.within(range: 1..100_000) }
    tickets_available { tickets_amount }
  end
end
