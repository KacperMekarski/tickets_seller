# frozen_string_literal: true

class Event < ApplicationRecord
  validates :name, :location, :happens_at, :ticket_price, :tickets_available, presence: true
  validates :ticket_price, numericality: { only_integer: true, greater_than_or_equal_to: 1 }
  validates :tickets_available, numericality: { only_integer: true, greater_than_or_equal_to: 0 }

  has_many :payments
  has_many :tickets
end
