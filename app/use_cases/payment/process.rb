class Payment::Process
  def self.call(payment_params)
    @payment = Payments::CreateForm.new(payment_params)
    @payment.submit
    Ticket::Generate.call(
      tickets_ordered_amount: @payment.tickets_ordered_amount,
      payment_id: @payment.new_payment.id
    )
    Event::UpdateAvailableTickets.call(
      @payment.new_payment.id
    )
    @payment
  end
end
