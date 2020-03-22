# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Payment::CreateForm, type: :model do
  subject(:payment_create_form) do
    Payment::CreateForm.new(
      payment = {
        paid_amount: paid_amount,
        tickets_ordered_amount: tickets_ordered_amount,
        currency: 'EUR',
        user_id: user.id,
        event_id: event.id
      }
    )
  end

  let(:user) { create(:user) }
  let!(:event) do
    create(
      :event,
      ticket_price: 10,
      tickets_available: 1000,
      tickets_amount: 1000
    )
  end

  describe '#submit' do
    let(:tickets_ordered_amount) { 1 }

    context 'when data is valid' do
      let(:paid_amount) { event.ticket_price }

      it 'calls payment adapter to check for errors' do
        expect(Payment::GatewayAdapter)
          .to receive(:check_for_errors)
          .with(token: :ok)
          .and_call_original

        subject.submit
      end

      it 'calls payment adapter to charge' do
        expect(Payment::GatewayAdapter)
          .to receive(:charge)
          .with(amount: paid_amount, currency: subject.currency)
          .and_call_original

        subject.submit
      end

      it 'calls payment repository to create payment' do
        expect(Payment::Repository)
          .to receive(:create)
          .with(subject)
          .and_call_original

        subject.submit
      end
    end

    context 'when data is invalid' do
      let(:paid_amount) { nil }

      it 'rolls back transaction' do
        expect { subject.submit }.to raise_exception Payment::GatewayAdapter::CardError
      end
    end
  end

  describe 'attributes' do
    let(:event) { create(:event) }
    let(:paid_amount) { event.ticket_price }
    let(:tickets_ordered_amount) { 1 }

    it { is_expected.to validate_presence_of(:currency) }
    it { is_expected.to validate_presence_of(:paid_amount) }
    it { is_expected.to validate_presence_of(:tickets_ordered_amount) }
    it {
      should validate_numericality_of(:paid_amount)
        .only_integer
        .is_greater_than_or_equal_to(1)
    }
  end

  describe 'validations' do
    describe 'payment_datetime' do
      let(:event) { create(:event, happens_at: happens_at) }
      let(:paid_amount) { event.ticket_price }
      let(:tickets_ordered_amount) { 1 }

      context 'when purchase is before the event' do
        let(:happens_at) { DateTime.tomorrow }

        it 'should validate that purchase is before event' do
          subject.valid?
          expect(subject.errors[:base].flatten)
            .not_to include('can not buy a ticket after the event')
        end
      end

      context 'when purchase is after the event' do
        let(:happens_at) { DateTime.yesterday }

        it 'should validate that purchase is after the event' do
          subject.valid?
          expect(subject.errors[:base].flatten)
            .to include('can not buy a ticket after the event')
        end
      end
    end

    describe 'change_is_left' do
      let(:event) { create(:event) }
      let(:tickets_ordered_amount) { 1 }

      context 'when change is not left from purchase' do
        let(:paid_amount) { event.ticket_price * 3 }

        it 'should validate there is no change' do
          subject.valid?
          expect(subject.errors[:base].flatten).not_to include('change is left')
        end
      end

      context 'when change is left from purchase' do
        let(:paid_amount) { event.ticket_price * 3 + 5213 }

        it 'should validate that change is left' do
          subject.valid?
          expect(subject.errors[:base].flatten).to include('change is left')
        end
      end
    end

    describe 'not_enough_money' do
      let(:event) { create(:event) }
      let(:tickets_ordered_amount) { 1 }

      context 'when paid amount is equal to price of the ticket' do
        let(:paid_amount) { event.ticket_price }

        it 'should validate there is enough money to buy a ticket' do
          subject.valid?
          expect(subject.errors[:base].flatten)
            .not_to include('not enough money to buy a ticket')
        end
      end

      context 'when paid amount is less than price of the ticket' do
        let(:paid_amount) { event.ticket_price - 5213 }

        it 'should validate there is not enough money to buy a ticket' do
          subject.valid?
          expect(subject.errors[:base].flatten)
            .to include('not enough money to buy a ticket')
        end
      end
    end

    describe 'lack_of_tickets' do
      let(:event) { create(:event, tickets_available: tickets_available) }
      let(:paid_amount) { event.ticket_price }
      let(:tickets_ordered_amount) { 1 }

      context 'when there are tickets available' do
        let(:tickets_available) { 130 }

        it 'should validate there are tickets available' do
          subject.valid?
          expect(subject.errors[:base].flatten).not_to include('lack of any tickets')
        end
      end

      context 'when there is lack of tickets' do
        let(:tickets_available) { 0 }

        it 'should validate there is lack of tickets' do
          subject.valid?
          expect(subject.errors[:base].flatten).to include('lack of any tickets')
        end
      end
    end

    describe 'not_enough_tickets' do
      let(:event) { create(:event, tickets_available: tickets_available) }
      let(:paid_amount) { event.ticket_price * tickets_ordered_amount }
      let(:tickets_ordered_amount) { 12 }

      context 'when there is more tickets than user wants to buy' do
        let(:tickets_available) { 25 }

        it 'should validate there is more tickets than user wants to buy' do
          subject.valid?
          expect(subject.errors[:base].flatten).not_to include('not enough tickets left')
        end
      end

      context 'when there is less tickets than user wants to buy' do
        let(:tickets_available) { 7 }

        it 'should validate there is less tickets than user wants to buy' do
          subject.valid?
          expect(subject.errors[:base].flatten).to include('not enough tickets left')
        end
      end
    end
  end
end
