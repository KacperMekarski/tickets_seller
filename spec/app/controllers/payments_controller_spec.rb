# frozen_string_literal: true

require 'rails_helper'
require 'json'

RSpec.describe Api::PaymentsController, type: :controller do
  describe 'POST #create' do
    before { post :create, params: { payment: payment_params, event_id: event.id }, format: :json }
    let!(:event) { create(:event, ticket_price: 10, tickets_available: tickets_available) }
    let!(:user) { create(:user) }
    let!(:response_data) { JSON.parse(response.body)['payment'] }

    shared_examples "payment response renderable" do
      it 'contains valid response data' do
        expect(response_data['event_id']).to eq(payment_params[:event_id])
        expect(response_data['user_id']).to eq(payment_params[:user_id])
        expect(response_data['paid_amount']).to eq(payment_params[:paid_amount])
        expect(response_data['currency']).to eq(payment_params[:currency])
        expect(response.content_type).to eq "application/json; charset=utf-8"
      end

      it 'should have unprocessable entity status' do
        expect(response.status).to eq(422)
      end

      it 'should not change amount of tickets' do
        expect { post :create, params: { payment: payment_params, event_id: event.id }, format: :json }.not_to change { Event.find(event.id).purchased_tickets.count }
        expect { post :create, params: { payment: payment_params, event_id: event.id }, format: :json }.not_to change { Event.find(event.id).tickets_available }
      end
    end

    context 'when payment is created' do
      let(:payment_params) { {
        user_id: user.id,
        event_id: event.id,
        paid_amount: 40,
        currency: "EUR"
        }
      }
      let(:tickets_available) { 1000 }

      it { expect(response_data['event_id']).to eq(payment_params[:event_id]) }
      it { expect(response_data['user_id']).to eq(payment_params[:user_id]) }
      it { expect(response_data['paid_amount']).to eq(payment_params[:paid_amount]) }
      it { expect(response_data['currency']).to eq(payment_params[:currency]) }
      it { expect(response_data["tickets"].count).to eq 4 }
      it "should increase number of purchased tickets by 4" do
        expect { post :create, params: { payment: payment_params, event_id: event.id }, format: :json }.to change { Event.find(event.id).purchased_tickets.count }.from(4).to(8)
      end
      it "should decrease number of available tickets by 4" do
        expect { post :create, params: { payment: payment_params, event_id: event.id }, format: :json }.to change { Event.find(event.id).tickets_available }.from(Event.find(event.id).tickets_available).to(Event.find(event.id).tickets_available - 4)
      end
      it { expect(response.status).to eq(200) }
      it { expect(response.content_type).to eq "application/json; charset=utf-8" }
    end

    context 'when payment is rejected' do
      let!(:reject_reason) { JSON.parse(response.body)['reject_reason'] }
      let(:payment_params) { {
        user_id: user.id,
        event_id: event.id,
        paid_amount: paid_amount,
        currency: "EUR"
        }
      }
      let(:tickets_available) { 1000 }

      context 'because change is left' do
        let(:paid_amount) { 12345 }
        let(:tickets_available) { 1000 }

        it_should_behave_like "payment response renderable"

        it { should rescue_from(Api::Adapters::Payment::Gateway::PaymentError).with(:render_record_invalid) }
        it { expect(reject_reason).to eq "Something went wrong with your transaction." }
        it { expect(response_data["errors"].values.flatten).to include('change is left') }
      end

      context 'because not enough money was paid' do
        let(:paid_amount) { 7 }
        let(:tickets_available) { 1000 }

        it_should_behave_like "payment response renderable"

        it { should rescue_from(Api::Adapters::Payment::Gateway::CardError).with(:render_record_invalid) }
        it { expect(reject_reason).to eq "Your card has been declined." }
        it { expect(response_data["errors"].values.flatten).to include('not enough money to buy a ticket') }
      end

      context 'because no tickets left' do
        let(:paid_amount) { 100 }
        let(:tickets_available) { 0 }

        it_should_behave_like "payment response renderable"

        it { should rescue_from(Api::Adapters::Payment::Gateway::PaymentError).with(:render_record_invalid) }
        it { expect(reject_reason).to eq "Something went wrong with your transaction." }
        it { expect(response_data["errors"].values.flatten).to include('lack of any tickets') }
      end

      context 'because there is not enough tickets left' do
        let(:paid_amount) { 100 }
        let(:tickets_available) { 5 }

        it_should_behave_like "payment response renderable"

        it { should rescue_from(Api::Adapters::Payment::Gateway::PaymentError).with(:render_record_invalid) }
        it { expect(reject_reason).to eq "Something went wrong with your transaction." }
        it { expect(response_data["errors"].values.flatten).to include('not enough tickets left') }
      end
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
          paid_amount: event.ticket_price,
          currency: "EUR"
        }
      }
      should permit(:user_id, :event_id, :paid_amount, :currency)
        .for(:create, params: params, verb: :post)
        .on(:payment)
    end
  end

  describe 'rescue_from' do
    it { should rescue_from(Api::Adapters::Payment::Gateway::CardError).with(:render_record_invalid) }
    it { should rescue_from(Api::Adapters::Payment::Gateway::PaymentError).with(:render_record_invalid) }
  end
end
