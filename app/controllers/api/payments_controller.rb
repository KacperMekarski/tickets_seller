# frozen_string_literal: true

class Api::PaymentsController < ApplicationController
  include Adapters::Payment::Gateway

  rescue_from ActiveRecord::RecordInvalid, with: :render_record_invalid
  # rescue_from CardError, with => :
  # rescue_from PaymentError, with => :

  class_attribute :json_payment

  self.json_payment = {
    only: %i[id name location happens_at ticket_price],
    methods: [:errors],
    include: [:tickets]
  }

  def create
    @payment = model_name.new(permitted_params)
    @payment.save!
    # 1. Tutaj ma zrobić charge z modułu, jak mu przekazać błędy z modelu?
    # 2. Tutaj ma wygenerować tyle biletów ile kupiono
    update_event_tickets_available
    render json: { model_name => @payment.as_json(json_payment) }
  end

  private

  def model_name
    controller_name.singularize
  end

  def permitted_params
    params.require(model_name).permit(:user_id, :event_id, :paid_amount)
  end

  def render_record_invalid
    render json: { model_name => @payment.as_json(json_payment) }, status: 422
  end

  def update_event_tickets_available
    @payment.event.update_available_tickets
  end
end
