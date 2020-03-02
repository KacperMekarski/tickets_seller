class Ticket::Data::Create
  def self.call(ticket_attributes)
    ticket_attributes.each { |payment_id| Ticket.create!(payment_id) }
  end
end
