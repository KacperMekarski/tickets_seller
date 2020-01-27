# frozen_string_literal: true

require 'rails_helper'
require 'json'

RSpec.describe Api::PaymentsController, type: :controller do
  # describe 'GET #show_basic_info' do
  #   before { post :create, params: { payment: { params }, :format => :json } }
  #   let!(:event) { create(:event) }
  #
  #   it "responds to json" do
  #     expect(response.content_type).to eq "application/json"
  #   end
  #
  #   context 'when payment is created' do
  #     let(:id) { event.id }
  #     let(:response_data) { JSON.parse(response.body)['event'] }
  #
  #     it { expect(response_data['id']).to eq(event.id) }
  #     it { expect(response_data['name']).to eq(event.name) }
  #     it { expect(response_data['location']).to eq(event.location) }
  #     it { expect(DateTime.parse(response_data['happens_at'])).to eq(event.happens_at) }
  #     it { expect(response_data['ticket_price']).to eq(event.ticket_price) }
  #     it { expect(response.status).to eq(200) }
  #   end
  #
  #   context 'when payment is rejected' do
  #     let(:id) { 12_345 }
  #     let(:response_data) { JSON.parse(response.body) }
  #
  #     it { expect(response_data).to eq("Couldn't find Event with 'id'=#{id}") }
  #     it { expect(response.status).to eq(404) }
  #   end
  # end

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
