# frozen_string_literal: true

class Event < ApplicationRecord
  validates :name, :location, :happens_at, :ticket_price, :tickets_amount, presence: true
  validates :ticket_price, numericality: { only_integer: true, greater_than_or_equal_to: 1 }
  validates :tickets_available, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
  validates :tickets_amount, numericality: { only_integer: true, greater_than_or_equal_to: 1 }, allow_blank: true

  has_many :payments
  has_many :purchased_tickets, through: :payments, class_name: 'Ticket'

  # before_create :set_available_tickets

  def update_available_tickets
    self.purchased_tickets.any? ? new_available_tickets_amount = self.tickets_amount - self.purchased_tickets.count : new_available_tickets_amount = self.tickets_amount
    self.update_column({ tickets_available: new_available_tickets_amount })
  end

  # def set_available_tickets
  #   self.tickets_available = self.tickets_amount
  # end
end
