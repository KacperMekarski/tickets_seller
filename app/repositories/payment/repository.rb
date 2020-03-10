class Payment::Repository
  def self.create(attributes)
    raise ArgumentError.new "Lack of attributes" unless attributes

    Payment.create!(
      paid_amount: attributes.paid_amount,
      currency: attributes.currency,
      event_id: attributes.event_id,
      user_id: attributes.user_id,
      tickets_ordered_amount: attributes.tickets_ordered_amount
    )
  end
end
