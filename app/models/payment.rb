# frozen_string_literal: true

class Payment < ApplicationRecord
  validates :paid_amount, presence: true
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
    if DateTime.now > event.happens_at
      errors.add(:base, 'can not buy a ticket after the event')
    end
  end

  def change_is_left
    unless paid_amount % event.ticket_price == 0
      errors.add(:base, 'can not buy an equal number of tickets, change is left')
    end
  end

  def not_enough_money
    if paid_amount < event.ticket_price
      errors.add(:base, 'not enough money to buy a ticket')
    end
  end

  def lack_of_tickets
    errors.add(:base, 'lack of any tickets') if event.tickets_available == 0
  end

  def not_enough_tickets
    if paid_amount / event.ticket_price > event.tickets_available
      errors.add(:base, 'not enough tickets left')
    end
  end
end
