class Ticket::Generate
  def self.call(tickets_ordered_amount:, payment_id:)
    @tickets = Ticket::Data::PrepareAttributes.call(
      tickets_number: tickets_ordered_amount.to_i,
      ticket_payment_id: payment_id
    )
    Ticket::Data::Create.call(@tickets)
  end
end
