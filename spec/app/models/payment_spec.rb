# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Payment, type: :model do
  describe 'validations' do
    subject(:payment) { create(:payment) }

    it { is_expected.to validate_presence_of(:paid_amount) }
    it { should validate_numericality_of(:paid_amount).only_integer.is_greater_than_or_equal_to(1) }

    describe 'check event_datetime' do
      subject(:payment) { build(:payment, event: event) }
      let(:event) { build(:event, happens_at: happens_at) }

      context 'when purchase is before the event' do
        let(:happens_at) { DateTime.tomorrow }

        it "should validate that purchase is before event" do
          subject.valid?
          expect(subject.errors[:base]).not_to include('can not buy a ticket after the event')
        end
      end

      context 'when purchase is after the event' do
        let(:happens_at) { DateTime.yesterday }

        it "should validate that purchase is after the event" do
          subject.valid?
          expect(subject.errors[:base]).to include('can not buy a ticket after the event')
        end
      end
    end

    describe 'check change_is_left' do
      subject(:payment) { build(:payment, paid_amount: paid_amount, event: event) }
      let(:event) { create(:event) }

      context 'when change is left from purchase' do
        let(:paid_amount) { event.ticket_price * 3 }

        it "should validate there is no change" do
          subject.valid?
          expect(subject.errors[:base]).not_to include('can not buy an equal number of tickets, change is left')
        end
      end

      context 'when change is not left from purchase' do
        let(:paid_amount) { event.ticket_price * 3 + 5213 }

        it "should validate that change is left" do
          subject.valid?
          expect(subject.errors[:base]).to include('can not buy an equal number of tickets, change is left')
        end
      end
    end
  end

  describe 'relations' do
    subject(:payment) { create(:payment) }

    it { is_expected.to belong_to(:user) }
    it { is_expected.to belong_to(:event) }
    it { is_expected.to have_many(:tickets) }
  end
end
