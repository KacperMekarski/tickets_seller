# frozen_string_literal: true

require 'rails_helper'
require 'json'

RSpec.describe Event::UpdateAvailableTickets do
  describe '.call' do
    subject(:call) { described_class.call(payment.id) }

    let!(:event) do
      create(
        :event,
        tickets_available: 100,
        tickets_amount: 100,
      )
    end

    let(:create_tickets) { create_list(:ticket, tickets_number, payment: payment) }
    let(:payment) { create(:payment, event: event) }

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
end
