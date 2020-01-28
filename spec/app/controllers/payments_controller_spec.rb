# frozen_string_literal: true

require 'rails_helper'
require 'json'

RSpec.describe Api::PaymentsController, type: :controller do
  describe 'POST #create' do
    before { post :create, params: { payment: payment_params, event_id: event.id }, format: :json }
    let!(:event) { create(:event, ticket_price: 100, tickets_available: 100) }
    let!(:user) { create(:user) }
    let(:payment_params) { {
      user_id: user.id,
      event_id: event.id,
      paid_amount: 10000
      }
    }

    it "responds to json" do
      expect(response.content_type).to eq "application/json; charset=utf-8"
    end

    context 'when payment is created' do
      let(:response_data) { JSON.parse(response.body)['payment'] }

      it { expect(response_data['event_id']).to eq(payment_params[:event_id]) }
      it { expect(response_data['user_id']).to eq(payment_params[:user_id]) }
      it { expect(response_data['paid_amount']).to eq(payment_params[:paid_amount]) }
      it { expect(response.status).to eq(200) }
    end

    context 'when payment is rejected' do
      # let(:response_data) { JSON.parse(response.body) }
      #
      # it { expect(response_data).to eq("Couldn't find Event with 'id'=#{id}") }
      # it { expect(response.status).to eq(404) }
    end
  end

  describe 'permitted params' do
    let!(:user) { create(:user) }
    let!(:event) { create(:event) }

    it do
      params = {
        event_id: event.id,
        payment: {
          user_id: user.id,
          event_id: event.id,
          paid_amount: event.ticket_price
        }
      }
      should permit(:user_id, :event_id, :paid_amount)
        .for(:create, params: params, verb: :post)
        .on(:payment)
    end
  end

  # describe 'rescue_from' do
  #   it { should rescue_from(ActiveRecord::RecordNotFound) }
  #   it { should rescue_from(CardError).with(:render_record_invalid) }
  #   it { should rescue_from(PaymentError).with(:render_record_invalid) }
  # end

  describe 'create tickets' do
    let(:user) { create(:user) }
    let(:event) { create(:event, ticket_price: 100, tickets_available: 100, tickets_amount: 100) }
    let(:payment) { create(:payment) }
    let(:payment_params) { { user_id: user.id, event_id: event.id, paid_amount: paid_amount } }

    context 'when number of purchased tickets is smaller than tickets amount at event' do
      let(:paid_amount) { 1000 }

      it 'should create demanded amount of tickets' do
        @payment = Api::PaymentsController.new
        @payment.send(:create_tickets, payment_params, payment.id)
        expect(Ticket.count).to eq 10
      end
    end

    context 'when number of purchased tickets is greater than tickets amount at event' do
      let(:paid_amount) { 11000 }

      it 'should raise an error' do
        @payment = Api::PaymentsController.new
        expect { @payment.send(:create_tickets, payment_params, payment.id) }.to raise_error(StandardError, 'not enough tickets left')
      end
    end
  end
end
