# frozen_string_literal: true

require 'rails_helper'
require 'json'

RSpec.describe Api::PaymentsController, type: :controller do
  describe 'POST #create' do
    subject(:post_create) { post :create, params: { payment: payment_params, event_id: event.id }, format: :json }
    let!(:event) { create(:event, ticket_price: 10, tickets_available: tickets_available, tickets_amount: tickets_amount) }
    let!(:user) { create(:user) }
    let(:response_data) { JSON.parse(response.body)['payment'] }

    shared_examples "payment response renderable" do
      it 'contains valid response data' do
        post_create
        expect(response_data['event_id']).to eq(payment_params[:event_id])
        expect(response_data['user_id']).to eq(payment_params[:user_id])
        expect(response_data['paid_amount']).to eq(payment_params[:paid_amount])
        expect(response_data['currency']).to eq(payment_params[:currency])
        expect(response.content_type).to eq "application/json; charset=utf-8"
      end

      it 'should have unprocessable entity status' do
        post_create
        expect(response.status).to eq(422)
      end

      it 'should not change amount of tickets' do
        expect { post_create }.not_to change { event.reload.purchased_tickets.count }
        expect { post_create }.not_to change { event.reload.tickets_available }
      end
    end

    context 'when payment is created' do
      let(:payment_params) { {
        user_id: user.id,
        event_id: event.id,
        paid_amount: 40,
        tickets_ordered_amount: 4,
        currency: "EUR"
        }
      }
      let(:tickets_available) { 1000 }
      let(:tickets_amount) { 1000 }

      it 'contains valid response data' do
        post_create
        expect(response_data['event_id']).to eq(payment_params[:event_id])
        expect(response_data['user_id']).to eq(payment_params[:user_id])
        expect(response_data['paid_amount']).to eq(payment_params[:paid_amount])
        expect(response_data['currency']).to eq(payment_params[:currency])
        expect(response_data["tickets"].count).to eq 4
        expect(response.content_type).to eq "application/json; charset=utf-8"
      end

      it "should increase number of purchased tickets by 4" do
        expect { post_create }.to change { event.reload.purchased_tickets.count }.by(4)
      end

      it "should decrease number of available tickets by 4" do
        expect { post_create }.to change { event.reload.tickets_available }.by(-4)
      end

      it 'should have ok status' do
        post_create
        expect(response.status).to eq(200)
      end
    end

    context 'when payment is rejected' do
      let(:reject_reason) { JSON.parse(response.body)['reject_reason'] }
      let(:payment_params) { {
        user_id: user.id,
        event_id: event.id,
        paid_amount: paid_amount,
        tickets_ordered_amount: tickets_ordered_amount,
        currency: "EUR"
        }
      }
      let(:tickets_available) { 1000 }
      let(:tickets_amount) { 1000 }

      context 'because change is left' do
        let(:paid_amount) { 12345 }
        let(:tickets_ordered_amount) { 1234 }
        let(:tickets_available) { 1000 }
        let(:tickets_amount) { 1000 }

        it_should_behave_like "payment response renderable"

        it 'should give errors' do
          post_create
          expect(reject_reason).to eq "Something went wrong with your transaction."
          expect(response_data["errors"].values.flatten).to include('change is left')
        end
      end

      context 'because not enough money was paid' do
        let(:paid_amount) { 7 }
        let(:tickets_ordered_amount) { 1 }
        let(:tickets_available) { 1000 }
        let(:tickets_amount) { 1000 }

        it_should_behave_like "payment response renderable"

        it 'should give errors' do
          post_create
          expect(reject_reason).to eq "Your card has been declined."
          expect(response_data["errors"].values.flatten).to include('not enough money to buy a ticket')
        end
      end

      context 'because no tickets left' do
        let(:paid_amount) { 100 }
        let(:tickets_ordered_amount) { 10 }
        let(:tickets_available) { 0 }
        let(:tickets_amount) { 100 }

        it_should_behave_like "payment response renderable"

        it 'should give errors' do
          post_create
          expect(reject_reason).to eq "Something went wrong with your transaction."
          expect(response_data["errors"].values.flatten).to include('lack of any tickets')
        end
      end

      context 'because there is not enough tickets left' do
        let(:paid_amount) { 100 }
        let(:tickets_ordered_amount) { 10 }
        let(:tickets_available) { 5 }
        let(:tickets_amount) { 100 }

        it_should_behave_like "payment response renderable"

        it 'should give errors' do
          post_create
          expect(reject_reason).to eq "Something went wrong with your transaction."
          expect(response_data["errors"].values.flatten).to include('not enough tickets left')
        end
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
          tickets_ordered_amount: 4,
          currency: "EUR"
        }
      }
      should permit(:user_id, :event_id, :paid_amount, :tickets_ordered_amount, :currency)
        .for(:create, params: params, verb: :post)
        .on(:payment)
    end
  end

  describe 'rescue_from' do
    it { should rescue_from(Api::Adapters::Payment::Gateway::CardError).with(:render_record_invalid) }
    it { should rescue_from(Api::Adapters::Payment::Gateway::PaymentError).with(:render_record_invalid) }
  end
end
