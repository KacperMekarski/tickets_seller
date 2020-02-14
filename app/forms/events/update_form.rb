class Events::UpdateForm
  include ActiveModel::Model

  attr_accessor(
    :name,
    :location,
    :happens_at,
    :ticket_price,
    :tickets_available,
    :tickets_amount
  )

  validates :name, :location, :happens_at, :ticket_price, :tickets_amount, presence: true
  validates :ticket_price, numericality: { only_integer: true, greater_than_or_equal_to: 1 }
  validates :tickets_available, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
  validates :tickets_amount, numericality: { only_integer: true, greater_than_or_equal_to: 1 }

  def update_event_tickets_available
    begin
      if valid?
        # Serwis?
        @new_payment.event.update_available_tickets!
        @success = true
      else
        @success = false
      end
    rescue => e
      self.errors.add(:base, e.message)
      @success = false
    end
  end

  def update_available_tickets!
    new_available_tickets_amount = purchased_tickets.any? ? tickets_amount - purchased_tickets.count : tickets_amount
    if new_available_tickets_amount < 0
      raise StandardError, 'can not buy more tickets than available'
    end

    update_columns(tickets_available: new_available_tickets_amount)
  end
end
