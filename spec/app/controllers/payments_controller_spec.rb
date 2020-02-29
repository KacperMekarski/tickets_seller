# frozen_string_literal: true

require 'rails_helper'
require 'json'

RSpec.describe Api::PaymentsController, type: :controller do
  describe 'POST #create' do
    before do
      post :create, params: { payment: payment_params, event_id: event.id }, as: :json
    end
    subject(:post_create) do
      post :create, params: { payment: payment_params, event_id: event.id }, as: :json
    end
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
    let(:response_data) { JSON.parse(response.body)['payment'] }

    shared_examples 'payment response renderable' do
      it 'contains valid response data' do
        expect(response_data['event_id'].to_i).to eq(payment_params[:event_id])
        expect(response_data['user_id'].to_i).to eq(payment_params[:user_id])
        expect(response_data['paid_amount'].to_i).to eq(payment_params[:paid_amount])
        expect(response_data['currency']).to eq(payment_params[:currency])
        expect(response.content_type).to eq 'application/json; charset=utf-8'
      end

      it 'has unprocessable entity status' do
        expect(response.status).to eq(422)
      end

      it 'does not change amount of tickets' do
        expect { post_create }.not_to change { event.reload.purchased_tickets.count }
        expect { post_create }.not_to change { event.reload.tickets_available }
      end
    end

    context 'when payment is created' do
      # TODO: params should be switched with payment_params
      let(:payment_params) do
        {
          user_id: user.id,
          event_id: event.id,
          paid_amount: 40,
          tickets_ordered_amount: 4,
          currency: 'EUR'
        }
      end
      let(:params) { ActionController::Parameters.new(payment_params) }
      let(:tickets_available) { 1000 }
      let(:tickets_amount) { 1000 }
      let(:happens_at) { 1.week.from_now }

      it 'contains valid response data' do
        expect(response_data['event_id']).to eq(payment_params[:event_id])
        expect(response_data['user_id']).to eq(payment_params[:user_id])
        expect(response_data['paid_amount']).to eq(payment_params[:paid_amount])
        expect(response_data['currency']).to eq(payment_params[:currency])
        expect(response_data['tickets'].count).to eq 4
        expect(response.content_type).to eq 'application/json; charset=utf-8'
      end

      it 'increases number of purchased tickets by 4' do
        expect { post_create }.to change { event.reload.purchased_tickets.count }.by(4)
      end

      it 'decreases number of available tickets by 4' do
        expect { post_create }.to change { event.reload.tickets_available }.by(-4)
      end

      it 'has 200 ok status' do
        expect(response.status).to eq(200)
      end

      it 'runs payment process' do
        params.permit!
        expect(Payment::Process)
          .to receive(:call).with(params)
                            .and_call_original

        post_create
      end
    end

    context 'when payment is rejected' do
      let(:reject_reason) { JSON.parse(response.body)['reject_reason'] }
      let(:payment_params) do
        {
          user_id: user.id,
          event_id: event.id,
          paid_amount: paid_amount,
          tickets_ordered_amount: tickets_ordered_amount,
          currency: 'EUR'
        }
      end
      let(:tickets_amount) { 1000 }

      context 'because change is left' do
        let(:tickets_available) { 1000 }
        let(:paid_amount) { 12_345 }
        let(:tickets_ordered_amount) { 1234 }
        let(:happens_at) { 1.week.from_now }

        it_should_behave_like 'payment response renderable'

        it 'gives errors' do
          expect(reject_reason).to eq 'Something went wrong with your transaction.'
          expect(response_data['errors'].values.flatten)
            .to include('change is left')
        end
      end

      context 'because not enough money was paid' do
        let(:tickets_available) { 1000 }
        let(:paid_amount) { 7 }
        let(:tickets_ordered_amount) { 1 }
        let(:happens_at) { 1.week.from_now }

        it_should_behave_like 'payment response renderable'

        it 'gives errors' do
          expect(reject_reason).to eq 'Your card has been declined.'
          expect(response_data['errors'].values.flatten)
            .to include('not enough money to buy a ticket')
        end
      end

      context 'because no tickets left' do
        let(:paid_amount) { 100 }
        let(:tickets_ordered_amount) { 10 }
        let(:tickets_available) { 0 }
        let(:happens_at) { 1.week.from_now }

        it_should_behave_like 'payment response renderable'

        it 'gives errors' do
          expect(reject_reason).to eq 'Something went wrong with your transaction.'
          expect(response_data['errors'].values.flatten)
            .to include('lack of any tickets')
        end
      end

      context 'because there is not enough tickets left' do
        let(:paid_amount) { 100 }
        let(:tickets_ordered_amount) { 10 }
        let(:tickets_available) { 5 }
        let(:happens_at) { 1.week.from_now }

        it_should_behave_like 'payment response renderable'

        it 'gives general error' do
          expect(reject_reason).to eq 'Something went wrong with your transaction.'
        end

        it 'gives error details' do
          expect(response_data['errors'].values.flatten)
            .to include('not enough tickets left')
        end
      end

      context 'because event is over' do
        let(:paid_amount) { 100 }
        let(:tickets_ordered_amount) { 2 }
        let(:happens_at) { 1.week.ago }
        let(:tickets_available) { 1000 }

        it_should_behave_like 'payment response renderable'

        it 'gives errors' do
          expect(reject_reason).to eq 'Something went wrong with your transaction.'
          expect(response_data['errors'].values.flatten)
            .to include('can not buy a ticket after the event')
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
          currency: 'EUR'
        }
      }
      should permit(:user_id, :event_id, :paid_amount, :tickets_ordered_amount, :currency)
        .for(:create, params: params, verb: :post)
        .on(:payment)
    end
  end

  describe 'rescue_from' do
    it {
      should rescue_from(Api::Adapters::Payment::Gateway::CardError)
        .with(:render_record_invalid)
    }
    it {
      should rescue_from(Api::Adapters::Payment::Gateway::PaymentError)
        .with(:render_record_invalid)
    }
  end
end
