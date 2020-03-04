# frozen_string_literal: true

class Event::UpdateAvailableTickets
  def self.call(payment_id)
    Payment.find(payment_id).event.update_available_tickets!
  end
end
