# frozen_string_literal: true

class Api::PaymentsController < ApplicationController
  # include Adapters::Payment::Gateway

  # rescue_from ActiveRecord::RecordInvalid
  # rescue_from CardError, with => :render_record_invalid
  # rescue_from PaymentError, with => :render_revord_invalid
  # rescue StandardError z metody gdzie zmniejsza ilosc dostepnych biletow
  class_attribute :json_payment

  self.json_payment = {
    only: %i[id name location happens_at ticket_price],
    methods: [:errors],
    include: [:tickets]
  }

  def create
    @payment = Payment.new(payment_params)
    if @payment.save!
      @payment.save!
      create_tickets(payment_params, @payment.id)
      update_event_tickets_available
      render json: { model_name => @payment.as_json(json_payment) }
    else
      token_errors = @payment.errors i zwraca tokeny w zależności od rodzaju błędu
      # Adapter::Payments::Gateaway.charge(@payment.paid_amount, token_errors, 'EUR')
    end
  end

  private

  def model_name
    controller_name.singularize
  end

  def payment_params
    params.require(:payment).permit(:user_id, :event_id, :paid_amount)
  end

  def render_record_invalid( general_error )
    render json: { model_name => @payment.as_json(json_payment), reject_reason: general_error.inspect }, status: 422
  end

  def update_event_tickets_available
    @payment.event.update_available_tickets
  end

  def create_tickets(payment_params, payment_id)
    tickets_number = calculate_number_of_tickets(payment_params)
    ticket_payment_id = { payment_id: payment_id }
    tickets = get_all_together(tickets_number, ticket_payment_id)
    Ticket.create(tickets)
  end

  def calculate_number_of_tickets(payment_params)
    paid_amount = payment_params[:paid_amount]
    ticket_price = Event.find(payment_params[:event_id]).ticket_price
    paid_amount / ticket_price
  end

  def get_all_together(tickets_number, ticket_payment_id)
    tickets = []
    tickets_number.times { tickets << ticket_payment_id }
    tickets
  end
end
