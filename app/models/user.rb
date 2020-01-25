# frozen_string_literal: true

class User < ApplicationRecord
  validates :email, presence: true, format: { with: /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\Z/i }
  validates_uniqueness_of :email
  validates :full_name, presence: true

  has_many :payments
  # has_many :tickets, through: :payments
end
