# PAYMENT ADAPTER
# frozen_string_literal: true

module Api
  module Adapters
    module Payment
      class Gateway
        CardError    = Class.new(StandardError)
        PaymentError = Class.new(StandardError)
        Result = Struct.new(:amount, :currency)

        class << self
          def check_for_errors(token:)
            case token.to_sym
            when :card_error
              raise CardError, 'Your card has been declined.'
            when :payment_error
              raise PaymentError, 'Something went wrong with your transaction.'
            end
          end

          def charge(amount:, currency: 'EUR')
            Result.new(amount, currency)
          end
        end
      end
    end
  end
end
