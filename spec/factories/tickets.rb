# frozen_string_literal: true

FactoryBot.define do
  factory :ticket do
    payment
    event
  end
end
