# frozen_string_literal: true

class Ticket::Repository
  def self.create(attributes)
    # raise ArgumentError.new "Lack of attributes" unless attributes

    attributes.each { |payment_id| Ticket.create!(payment_id) }
  end
end
