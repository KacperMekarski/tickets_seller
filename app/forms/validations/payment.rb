class Validations::Payment < Dry::Validation::Contract
  params do
    required(:paid_amount).value(:integer)
    required(:user_id).value(:integer)
    required(:event_id).value(:integer)
    required(:currency).value(:string)
    required(:tickets_ordered_amount).value(:integer)
  end

  rule(:event_id) do
    base.failure('can not buy a ticket after the event')
      if Time.current > Event.find(value.to_i).happens_at
  end

  rule(:event_id) do
    base.failure('lack of any tickets')
      if Event.find(value.to_i).tickets_available == 0
  end

  rule(:paid_amount, :event_id) do
    base.failure('change is left')
      unless values[:paid_amount].to_i % Event.find(values[:event_id].to_i)
                                         .ticket_price == 0
  end

  rule(:paid_amount, :event_id) do
    base.failure('not enough money to buy a ticket')
      if values[:paid_amount].to_i < Event.find(values[:event_id].to_i)
                                     .ticket_price
  end

  rule(:tickets_ordered_amount, :event_id) do
    tickets_available = Event.find(values[:event_id].to_i).tickets_available
    base.failure('not enough tickets left')
      if values[:tickets_ordered_amount] > tickets_available
  end
end
