# frozen_string_literal: true

require 'rails_helper'
require 'json'

RSpec.describe Ticket::Create do
  describe '.call' do
    subject(:call) { described_class.call(
      tickets_ordered_amount: tickets_ordered_amount,
      payment_id: payment.id
      )
    }

    let!(:payment) { create(:payment) }

    let(:tickets_ordered_amount) { 2 }
    let(:payment_id) { payment.id }

    it 'calls payment create form' do
      expect(Ticket::PrepareTicketsAttributes)
        .to receive(:call)
        .with(
          tickets_number: tickets_ordered_amount,
          ticket_payment_id: payment_id
        )
        .and_call_original

      call
    end

    context 'when there are ordered tickets' do
      it { expect { subject }.to change { Ticket.count }.by(2) }
    end

    context 'when there are not any ordered tickets' do
      let(:tickets_ordered_amount) { 0 }

      it { expect { subject }.to change { Ticket.count }.by(0) }
    end
  end
end
