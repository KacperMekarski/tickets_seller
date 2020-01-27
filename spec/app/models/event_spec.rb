# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Event, type: :model do
  describe 'validations' do
    subject(:event) { create(:event) }

    it { is_expected.to validate_presence_of(:name) }
    it { is_expected.to validate_presence_of(:location) }
    it { is_expected.to validate_presence_of(:happens_at) }
    it { is_expected.to validate_presence_of(:ticket_price) }
    it { is_expected.to validate_presence_of(:tickets_amount) }
    it { should validate_numericality_of(:ticket_price).only_integer.is_greater_than_or_equal_to(1) }
    it { should validate_numericality_of(:tickets_available).only_integer.is_greater_than_or_equal_to(0).on(:update) }
    it { should validate_numericality_of(:tickets_amount).only_integer.is_greater_than_or_equal_to(1) }
  end

  describe 'relations' do
    it { is_expected.to have_many(:payments) }
    it { is_expected.to have_many(:purchased_tickets).through(:payments).source(:tickets) }
  end

  describe 'instance methods' do
    describe 'set_available_tickets' do
      subject(:event) { create(:event, tickets_amount: 100, tickets_available: 100) }

      context 'when no ticket was purchased' do
        it 'should set tickets_available to tickets_amount' do
          event.update_available_tickets
          expect(subject.tickets_available).to eq event.tickets_amount
        end
      end

      context 'when some tickets were purchased' do
        let!(:ticket) { create_list(:ticket, 15, payment: payment) }
        let!(:payment) { create(:payment, event: event) }

        it 'should reduce number of tickets_available by purchased tickets' do
          event.update_available_tickets
          expect(event.tickets_available).to eq 85
        end
      end

      context 'when user purchased more tickets than available' do
        let!(:ticket) { create_list(:ticket, 125, payment: payment) }
        let!(:payment) { create(:payment, event: event) }

        it { expect { event.update_available_tickets }.to raise_error(StandardError, 'can not buy more tickets than available') }
      end
    end
  end
  # TODO
  # describe 'callbacks' do
  #   describe  'set_available_tickets' do
  #     context 'when created' do
  #       subject(:event) { build(:event) }
  #
  #       it "triggers set_available_tickets on create" do
  #         is_expected.to receive(:set_available_tickets)
  #         subject.save
  #       end
  #
  #       it 'should have available tickets equal to tickets amount' do
  #         subject.set_available_tickets
  #         expect(subject.tickets_available).to eq event.tickets_amount
  #       end
  #     end
  #
  #     context 'when updated' do
  #       subject(:event) { create(:event) }
  #       let(:name) { 'RHCP concert' }
  #
  #       it "does not trigger set_available_tickets on update" do
  #         is_expected.not_to receive(:set_available_tickets)
  #         subject.update(name: name)
  #       end
  #     end
  #   end
  # end
end
