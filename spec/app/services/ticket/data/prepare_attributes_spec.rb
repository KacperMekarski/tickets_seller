# frozen_string_literal: true

require 'rails_helper'
require 'json'

RSpec.describe Ticket::Data::PrepareAttributes do
  describe '.call' do
    subject(:call) { described_class.call(
      tickets_number: tickets_ordered_amount,
      ticket_payment_id: payment_id
      )
    }

    context 'when data is valid' do
      context 'when tickets number is more than 0' do
        let(:tickets_ordered_amount) { 5 }
        let(:payment_id) { 1 }
        let(:array_of_hashes) {
          [
            { payment_id: 1 },
            { payment_id: 1 },
            { payment_id: 1 },
            { payment_id: 1 },
            { payment_id: 1 },
          ]
        }

        it 'creates array of hashes with payment_id' do
          is_expected.to eq array_of_hashes
        end
      end

      context 'when tickets number is equal to 0' do
        let(:tickets_ordered_amount) { 0 }
        let(:payment_id) { 1 }

        it 'creates array of hashes with payment_id' do
          is_expected.to eq []
        end
      end
    end
  end
end
