# frozen_string_literal: true

require 'rails_helper'
require 'json'

RSpec.describe Event::UpdateAvailableTickets do
  describe '.call' do
    subject(:call) { described_class.call(payment_id) }

    let!(:event) do
      create(
        :event,
        tickets_available: 100,
        tickets_amount: 100,
      )
    end

    let(:create_tickets) { create_list(:ticket, tickets_number, payment: payment) }

    context 'when payment was found' do
      let(:payment) { create(:payment, event: event) }
      let(:payment_id) { payment.id }

      context 'when tickets are purchased' do
        let(:tickets_number) { 15 }

        it 'decreases event available tickets by amount of purchased tickets' do
          create_tickets

          expect { subject }.to change { event.reload.tickets_available }.by(-15)
        end
      end

      context 'when no tickets were purchased' do
        let(:tickets_number) { 0 }

        it 'does nothing with amount of available tickets' do
          create_tickets

          expect { subject }.to change { event.reload.tickets_available }.by(0)
        end
      end
    end

    context 'when payment was not found' do
      let(:payment_id) { 32 }

      it 'raises ActiveRecord::RecordNotFound error' do
        expect { subject }.to raise_error(ActiveRecord::RecordNotFound)
      end
    end

    context 'when payment was not created' do
      let(:payment) { nil }
      let(:payment_id) { payment.id }

      it 'raises ActiveRecord::RecordNotFound error' do
        expect { subject }.to raise_error(NoMethodError)
      end
    end
  end
end
