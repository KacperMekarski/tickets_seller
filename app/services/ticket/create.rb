class Ticket::Create
  def self.call(tickets_ordered_amount:, payment_id:)
    @tickets = Ticket::PrepareTicketsAttributes.call(
      tickets_number: tickets_ordered_amount.to_i,
      ticket_payment_id: payment_id
    )
    @tickets.each { |payment_id| Ticket.create!(payment_id) }
  end
end
