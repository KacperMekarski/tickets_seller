# frozen_string_literal: true

require 'rails_helper'
require 'json'

RSpec.describe Ticket::Data::Create do
  describe '.call' do
    subject(:call) do
      described_class.call(
        ticket_attributes
      )
    end

    let!(:payment) { create(:payment) }

    context 'when data is valid' do
      context 'when ticket params are passed' do
        let(:ticket_attributes) do
          [
            { payment_id: payment.id },
            { payment_id: payment.id }
          ]
        end

        it 'saves tickets to database' do
          expect { subject }.to change { Ticket.count }.by(2)
        end
      end
    end

    context 'when data is invalid' do
      context 'when there are not any ordered tickets' do
        let(:ticket_attributes) { [] }

        it 'does not save any ticket to database' do
          expect { subject }.to change { Ticket.count }.by(0)
        end
      end

      context 'when payment is not found' do
        let(:ticket_attributes) do
          [
            { payment_id: 12_345 },
            { payment_id: 12_345 }
          ]
        end

        it { expect { subject }.to raise_error(ActiveRecord::RecordInvalid) }
      end
    end
  end
end
