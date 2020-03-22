# frozen_string_literal: true

class Payment::CreateForm
  include ActiveModel::Model

  def initialize(payment_params)
    @params = payment_params
    @new_payment = {}
  end

  attr_accessor(
    :params,
    :new_payment
  )

  # validates :paid_amount, :currency, :tickets_ordered_amount, presence: true
  # validates :paid_amount, numericality: {
  #                                         only_integer: true,
  #                                         greater_than_or_equal_to: 1
  #                                       }

  validate :dry_validation

  def submit
    ActiveRecord::Base.transaction do
      Payment::GatewayAdapter.check_for_errors(token: check_if_valid)

      @new_payment = Payment::Repository.create(self)

      Payment::GatewayAdapter.charge(
        amount: paid_amount,
        currency: currency
      )
    end
  end

  private

  def dry_validation
    Validations::Payment.new.call(@params).errors.to_h.each do |field, message|
      field = :base if field.nil?
      errors.add(field, message)
    end
  end

  def check_if_valid
    if valid?
      :ok
    elsif errors.messages.values.flatten.include?('not enough money to buy a ticket')
      :card_error
    else
      :payment_error
    end
  end
end
