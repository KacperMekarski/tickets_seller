# frozen_string_literal: true

class Payment < ApplicationRecord
  validates :paid_amount, presence: true
  validates :paid_amount, numericality: { only_integer: true, greater_than_or_equal_to: 1 }

  belongs_to :user
  belongs_to :event

  # has_many :tickets
end
