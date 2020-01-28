# frozen_string_literal: true

FactoryBot.define do
  factory :payment do
    paid_amount { event.ticket_price * Faker::Number.within(range: 1..10) }
    currency { Faker::Currency.code }
    user
    event
  end
end
