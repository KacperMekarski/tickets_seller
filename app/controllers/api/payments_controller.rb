# frozen_string_literal: true

class Api::PaymentsController < ApplicationController
  include Adapters::Payment::Gateway

  rescue_from ActiveRecord::RecordInvalid
  # , with: :render_record_invalid
  # rescue_from CardError, with => :render_record_invalid
  # rescue_from PaymentError, with => :render_revord_invalid
  # I tak jest dobrze bo najpierw ma wywalać po CardError, jak tylko zrobić żeby w CardError pokazywalo .errors tylko z nią związane?
  # rescue StandardError z metody gdzie zmniejsza ilosc dostepnych biletow
  class_attribute :json_payment

  self.json_payment = {
    only: %i[id name location happens_at ticket_price],
    methods: [:errors],
    include: [:tickets]
  }

  def create
    @payment = model_name.new(permitted_params)
    # 1. Tutaj ma zrobić charge z modułu, jak mu przekazać błędy z modelu?
    token_errors = zrób tu metodę która ma w sobie @payment.errors i zwraca tokeny w zależności od rodzaju błędu.
    Adapter::Payments::Gateaway.charge(@payment.paid_amount, token_errors, "EUR")
    # Jak wsadzic do responsa CardError lub PaymentError do struktury powyżej?
    @payment.save!
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
