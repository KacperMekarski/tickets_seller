class Payment::Process
  def self.call(payment_params)
    Payments::CreateForm.new(payment_params).submit
    # Ticket::Create.call
    # create_tickets(self, @new_payment.id)
    # update_event_tickets_available
  end
end
