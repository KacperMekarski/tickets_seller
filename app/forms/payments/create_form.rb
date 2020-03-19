# frozen_string_literal: true

class Payments::CreateForm
  include ActiveModel::Model

  attr_accessor(
    :paid_amount,
    :user_id,
    :event_id,
    :currency,
    :tickets_ordered_amount,
    :new_payment
  )

  validates :paid_amount, :currency, :tickets_ordered_amount, presence: true
  validates :paid_amount, numericality: {
                                          only_integer: true,
                                          greater_than_or_equal_to: 1
                                        }

  validate :payment_datetime
  validate :change_is_left
  validate :not_enough_money
  validate :lack_of_tickets
  validate :not_enough_tickets

  def submit
    ActiveRecord::Base.transaction do
      PaymentAdapter::GatewayAdapter.check_for_errors(token: check_if_valid)

      @new_payment = Payment::Repository.create(self)

      PaymentAdapter::GatewayAdapter.charge(
        amount: paid_amount,
        currency: currency
      )
    end
  end

  private

  def check_if_valid
    if valid?
      :ok
    elsif errors.messages.values.flatten.include?('not enough money to buy a ticket')
      :card_error
    else
      :payment_error
    end
  end

  def payment_datetime
    if Time.current > Event.find(event_id.to_i).happens_at
      errors.add(:base, 'can not buy a ticket after the event')
    end
  end

  def change_is_left
    unless paid_amount.to_i % Event.find(event_id.to_i).ticket_price == 0
      errors.add(:base, 'change is left')
    end
  end

  def not_enough_money
    if paid_amount.to_i < Event.find(event_id.to_i).ticket_price
      errors.add(:base, 'not enough money to buy a ticket')
    end
  end

  def lack_of_tickets
    if Event.find(event_id.to_i).tickets_available == 0
      errors.add(:base, 'lack of any tickets')
    end
  end

  def not_enough_tickets
    tickets_number = tickets_ordered_amount.to_i
    event_id = self.event_id.to_i
    tickets_available = Event.find(event_id).tickets_available
    if tickets_number > tickets_available
      errors.add(:base, 'not enough tickets left')
    end
  end
end
