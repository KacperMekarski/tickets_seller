# frozen_string_literal: true

FactoryBot.define do
  factory :payment do
    paid_amount { event.ticket_price * Faker::Number.within(range: 1..10) }
    tickets_ordered_amount { Faker::Number.between(from: 1, to: 5) }
    currency { Faker::Currency.code }
    user
    event
  end
end
