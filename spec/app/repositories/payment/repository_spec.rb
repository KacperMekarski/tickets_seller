# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Payment::Repository do
  subject(:create_payment_repository) do
    described_class.create( attributes )
  end

  let!(:user) { create(:user) }
  let!(:event) { create(:event) }

  context 'when data is valid' do
    let(:attributes) { build(:payment, event: event, user: user) }

    it 'saves tickets to database' do
      expect { subject }.to change { Payment.count }.by(1)
    end

    it 'calls create payment' do
      expect(Payment)
        .to receive(:create!)
        .with(
          paid_amount: attributes.paid_amount,
          currency: attributes.currency,
          event_id: attributes.event_id,
          user_id: attributes.user_id,
          tickets_ordered_amount: attributes.tickets_ordered_amount
        )
        .and_call_original

      create_payment_repository
    end
  end

  context 'when data is invalid' do
    context 'when argument is missing' do
      let(:attributes) { nil }

      it { expect { subject }.to raise_error(ArgumentError) }
    end

    context 'when event is not found' do
      let(:attributes) { build(:payment, event_id: 12, user: user) }

      it { expect { subject }.to raise_error(ActiveRecord::RecordInvalid) }
    end

    context 'when user is not found' do
      let(:attributes) { build(:payment, event: event, user_id: 12) }

      it { expect { subject }.to raise_error(ActiveRecord::RecordInvalid) }
    end
  end
end
