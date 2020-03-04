# frozen_string_literal: true

require 'rails_helper'
require 'json'

RSpec.describe Ticket::Generate do
  describe '.call' do
    subject(:call) { described_class.call(
      tickets_ordered_amount: tickets_ordered_amount,
      payment_id: payment_id
      )
    }

    let!(:payment) { create(:payment) }

    let(:tickets_ordered_amount) { 2 }
    let(:payment_id) { payment.id }
    let(:ticket_attributes) {
      [
        { payment_id: payment_id },
        { payment_id: payment_id }
      ]
    }

    it 'calls prepare attributes' do
      expect(Ticket::Data::PrepareAttributes)
        .to receive(:call)
        .with(
          tickets_number: tickets_ordered_amount,
          ticket_payment_id: payment_id
        )
        .and_return(ticket_attributes)
        .and_call_original

      call
    end

    it 'calls create tickets' do
      expect(Ticket::Data::Create)
        .to receive(:call)
        .with(ticket_attributes)
        .and_call_original

      call
    end
  end
end
