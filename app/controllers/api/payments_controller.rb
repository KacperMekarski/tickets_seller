# frozen_string_literal: true

class Api::PaymentsController < ApplicationController
  # rescue_from ActiveRecord::RecordInvalid
  # rescue_from CardError, with => :render_record_invalid
  # rescue_from PaymentError, with => :render_revord_invalid
  # rescue StandardError z metody gdzie zmniejsza ilosc dostepnych biletow i gdzie tworzy bilety
  class_attribute :json_payment

  self.json_payment = {
    only: %i[id event_id user_id paid_amount currency],
    methods: [:errors],
    include: {
      tickets: {
        only: %i[id payment_id created_at]
      }
    }
  }

  def create
    token = check_if_valid(payment_params)
    payment = Api::Adapters::Payment::Gateway.charge(amount: payment_params[:paid_amount], token: token)
    @new_payment = Payment.create(paid_amount: payment.amount, currency: payment.currency, event_id: payment_params[:event_id], user_id: payment_params[:user_id])
    create_tickets(payment_params, @new_payment.id)
    update_event_tickets_available
    render json: { model_name => @new_payment.as_json(json_payment) }
  end

  private

  def check_if_valid(payment_params)
    @payment = Payment.new(payment_params)
    @payment.valid?
    if @payment.valid?
      return :ok
    elsif @payment.errors.messages.values.flatten.include?('not enough money to buy a ticket')
      return :card_error
    else
      return :payment_error
    end
  end

  def model_name
    controller_name.singularize
  end

  def payment_params
    params.require(:payment).permit(:user_id, :event_id, :paid_amount, :currency)
  end

  def render_record_invalid(general_error)
    render json: { model_name => @payment.as_json(json_payment), reject_reason: general_error.inspect }, status: 422
  end

  def update_event_tickets_available
    @new_payment.event.update_available_tickets
  end

  def create_tickets(payment_params, payment_id)
    tickets_number = calculate_number_of_tickets(payment_params)
    check_if_enough_tickets_left(tickets_number, payment_params[:event_id])
    ticket_payment_id = { payment_id: payment_id }
    tickets = get_all_together(tickets_number, ticket_payment_id)
    Ticket.create(tickets)
  end

  def calculate_number_of_tickets(payment_params)
    paid_amount = payment_params[:paid_amount]
    ticket_price = Event.find(payment_params[:event_id]).ticket_price
    paid_amount.to_i / ticket_price.to_i
  end

  def get_all_together(tickets_number, ticket_payment_id)
    tickets = []
    tickets_number.times { tickets << ticket_payment_id }
    tickets
  end

  def check_if_enough_tickets_left(tickets_number, event_id)
    tickets_available = Event.find(event_id).tickets_available
    raise StandardError, 'not enough tickets left' if tickets_number > tickets_available
  end
end
