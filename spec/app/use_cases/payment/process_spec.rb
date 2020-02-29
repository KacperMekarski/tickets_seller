# frozen_string_literal: true

require 'rails_helper'
require 'json'

RSpec.describe Payment::Process do
  describe '.call' do
    subject(:call) { described_class.call(payment_params) }

    let!(:event) do
      create(
        :event,
        ticket_price: 10,
        tickets_available: tickets_available,
        tickets_amount: tickets_amount,
        happens_at: happens_at
      )
    end
    let!(:user) { create(:user) }
    let(:payment_params) do
      {
        user_id: user.id,
        event_id: event.id,
        paid_amount: 40,
        tickets_ordered_amount: 4,
        currency: 'EUR'
      }
    end
    let(:tickets_available) { 1000 }
    let(:tickets_amount) { 1000 }
    let(:happens_at) { 1.week.from_now }

    it 'calls payment create form' do
      expect(Payments::CreateForm)
        .to receive(:new)
        .with(payment_params)
        .and_call_original

      call
    end

    it 'submits that form' do
      expect_any_instance_of(Payments::CreateForm)
        .to receive(:submit)
        .and_call_original

      call
    end
  end
end
