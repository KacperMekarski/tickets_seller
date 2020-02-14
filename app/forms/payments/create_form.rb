class Payments::CreateForm
  include ActiveModel::Model

  attr_accessor(
    :paid_amount,
    :user_id,
    :event_id,
    :currency,
    :tickets_ordered_amount
  )

  validates :paid_amount, :currency, :tickets_ordered_amount, presence: true
  validates :paid_amount, numericality: { only_integer: true, greater_than_or_equal_to: 1 }

  validate :payment_datetime, on: :create
  validate :change_is_left, on: :create
  validate :not_enough_money, on: :create
  validate :lack_of_tickets, on: :create
  validate :not_enough_tickets, on: :create

  def save
    # To wszystko trzeba przenieść do serwisu
    ActiveRecord::Base.transaction do
      begin
        # Valid will setup the Form object errors
        if valid?
          register!
          Tickets::CreateForm.create!
          Events::UpdateForm.update!
          @success = true
        else
          @success = false
        end
      rescue => e
        self.errors.add(:base, e.message)
        @success = false
      end
    end

  private

  def payment_datetime
    if Time.current > event.happens_at
      errors.add(:base, 'can not buy a ticket after the event')
    end
  end

  def change_is_left
    unless paid_amount % event.ticket_price == 0
      errors.add(:base, 'change is left')
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
    if paid_amount / event.ticket_price > event.tickets_available && paid_amount % event.ticket_price == 0
      errors.add(:base, 'not enough tickets left')
    end
  end
end
