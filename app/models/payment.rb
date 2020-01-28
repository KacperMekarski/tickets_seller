# frozen_string_literal: true

class Payment < ApplicationRecord
  validates :paid_amount, :currency, presence: true
  validates :paid_amount, numericality: { only_integer: true, greater_than_or_equal_to: 1 }

  validate :payment_datetime, on: :create
  validate :change_is_left, on: :create
  validate :not_enough_money, on: :create
  validate :lack_of_tickets, on: :create
  validate :not_enough_tickets, on: :create

  belongs_to :user
  belongs_to :event

  has_many :tickets

  private

  def payment_datetime
    if DateTime.now > self.event.happens_at
      errors.add(:base, 'can not buy a ticket after the event')
    end
  end

  def change_is_left
    errors.add(:base, 'change is left') unless paid_amount % event.ticket_price == 0
  end

  def not_enough_money
    errors.add(:base, 'not enough money to buy a ticket') if paid_amount < event.ticket_price
  end

  def lack_of_tickets
    errors.add(:base, 'lack of any tickets') if event.tickets_available == 0
  end

  def not_enough_tickets
    errors.add(:base, 'not enough tickets left') if paid_amount / event.ticket_price > event.tickets_available && paid_amount % event.ticket_price == 0
  end
end
