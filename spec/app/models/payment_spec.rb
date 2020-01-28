# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Payment, type: :model do
  describe 'relations' do
    subject(:payment) { create(:payment) }

    it { is_expected.to belong_to(:user) }
    it { is_expected.to belong_to(:event) }
    it { is_expected.to have_many(:tickets) }
  end

  describe 'validations' do
    subject(:payment) { create(:payment) }

    it { is_expected.to validate_presence_of(:currency) }
    it { is_expected.to validate_presence_of(:paid_amount) }
    it { should validate_numericality_of(:paid_amount).only_integer.is_greater_than_or_equal_to(1) }

    # TODO
    # describe 'payment_datetime' do
    #   subject(:payment) { build(:payment, event: event) }
    #   let(:event) { build(:event, happens_at: happens_at) }
    #
    #   context 'when purchase is before the event' do
    #     let(:happens_at) { DateTime.tomorrow }
    #
    #     it 'should validate that purchase is before event' do
    #       subject.valid?
    #       expect(subject.errors[:base]).not_to include('can not buy a ticket after the event')
    #     end
    #   end
    #
    #   context 'when purchase is after the event' do
    #     let(:happens_at) { DateTime.yesterday }
    #
    #     it 'should validate that purchase is after the event' do
    #       subject.valid?
    #       expect(subject.errors[:base]).to include('can not buy a ticket after the event')
    #     end
    #   end
    # end

    describe 'change_is_left' do
      subject(:payment) { build(:payment, paid_amount: paid_amount, event: event) }
      let(:event) { create(:event) }

      context 'when change is not left from purchase' do
        let(:paid_amount) { event.ticket_price * 3 }

        it 'should validate there is no change' do
          subject.valid?
          expect(subject.errors[:base]).not_to include('change is left')
        end
      end

      context 'when change is left from purchase' do
        let(:paid_amount) { event.ticket_price * 3 + 5213 }

        it 'should validate that change is left' do
          subject.valid?
          expect(subject.errors[:base]).to include('change is left')
        end
      end
    end

    describe 'not_enough_money' do
      subject(:payment) { build(:payment, paid_amount: paid_amount, event: event) }
      let(:event) { create(:event) }

      context 'when paid amount is equal to price of the ticket' do
        let(:paid_amount) { event.ticket_price }

        it 'should validate there is enough money to buy a ticket' do
          subject.valid?
          expect(subject.errors[:base]).not_to include('not enough money to buy a ticket')
        end
      end

      context 'when paid amount is less than price of the ticket' do
        let(:paid_amount) { event.ticket_price - 5213 }

        it 'should validate there is not enough money to buy a ticket' do
          subject.valid?
          expect(subject.errors[:base]).to include('not enough money to buy a ticket')
        end
      end
    end

    describe 'lack_of_tickets' do
      subject(:payment) { build(:payment, event: event) }
      let(:event) { create(:event, tickets_available: tickets_available) }

      context 'when there are tickets available' do
        let(:tickets_available) { 130 }

        it 'should validate there are tickets available' do
          subject.valid?
          expect(subject.errors[:base]).not_to include('lack of any tickets')
        end
      end

      context 'when there is lack of tickets' do
        let(:tickets_available) { 0 }

        it 'should validate there is lack of tickets' do
          subject.valid?
          expect(subject.errors[:base]).to include('lack of any tickets')
        end
      end
    end

    describe 'not_enough_tickets' do
      subject(:payment) { build(:payment, paid_amount: paid_amount, event: event) }
      let(:event) { create(:event, tickets_available: tickets_available) }
      let(:paid_amount) { event.ticket_price * 10 }

      context 'when there is more tickets than user wants to buy' do
        let(:tickets_available) { 25 }

        it 'should validate there is more tickets than user wants to buy' do
          subject.valid?
          expect(subject.errors[:base]).not_to include('not enough tickets left')
        end
      end

      context 'when there is less tickets than user wants to buy' do
        let(:tickets_available) { 7 }

        it 'should validate there is less tickets than user wants to buy' do
          subject.valid?
          expect(subject.errors[:base]).to include('not enough tickets left')
        end
      end
    end
  end
end
