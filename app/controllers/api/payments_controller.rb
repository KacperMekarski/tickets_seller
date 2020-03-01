# frozen_string_literal: true

class Api::PaymentsController < ApplicationController
  require 'json'
  # rescue_from ActiveRecord::RecordInvalid
  rescue_from Api::Adapters::Payment::Gateway::CardError, with: :render_record_invalid
  rescue_from Api::Adapters::Payment::Gateway::PaymentError, with: :render_record_invalid
  # rescue_from StandardError, with: :render_record_invalid
  class_attribute :json_payment

  self.json_payment = {
    only: %i[id event_id user_id paid_amount tickets_ordered_amount currency],
    methods: [:errors],
    include: {
      tickets: {
        only: %i[id payment_id created_at]
      }
    }
  }

  def create
    @payment = Payment::Process.call(payment_params)

    render json: { payment: @payment.new_payment.as_json(json_payment) }
  end

  private

  def payment_params
    params.require(:payment).permit(:user_id, :event_id, :paid_amount, :currency, :tickets_ordered_amount)
  end

  def render_record_invalid(reject_reason)
    @failed_payment = Payments::CreateForm.new(payment_params)
    @failed_payment.valid?
    render json: { payment: @failed_payment.as_json, reject_reason: reject_reason.message }, status: 422
  end
end
