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
    include: :tickets
  }

  def create
    @payment = model_name.new(permitted_params)
    # 1. Tutaj w modelu lecą walidacje, czy można dokonać płatności.
    @payment.save!
    # 2. Tutaj ma zrobić charge z modułu, jak mu przekazać błędy z modelu?
    # 3. Tutaj ma wygenerować tyle biletów ile kupiono
    # 4. Tutaj ma zaktualizować ile zostało dostępnych biletów.
    render json: { model_name => @resource.as_json(json_payment) }
  end

  private

  def model_name
    controller_name.singularize
  end

  def permitted_params
    params.require(model_name).permit(:user_id, :event_id, :paid_amount)
  end

  def render_record_invalid
    render json: { model_name => @resource.as_json(json_payment) }, status: 422
  end
end
