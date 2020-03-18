# frozen_string_literal: true

require 'rails_helper'

RSpec.describe PaymentAdapter::GatewayAdapter do
  describe "#check_for_errors" do
    subject(:check_for_errors) do
      described_class.check_for_errors( token: token )
    end

    context 'when it receives card error token' do
      let(:token) { :card_error }

      it { expect { subject }.to raise_error(PaymentAdapter::GatewayAdapter::CardError) }
    end

    context 'when it reveices payment error token' do
      let(:token) { :payment_error }

      it { expect { subject }.to raise_error(PaymentAdapter::GatewayAdapter::PaymentError) }
    end
  end

  describe "#charge" do
    subject(:charge) do
      described_class.charge(amount: amount)
    end

    let(:amount) { 25 }
    let(:currency) { "EUR" }

    let(:result) do
      PaymentAdapter::GatewayAdapter::Result.new(amount, currency)
    end

    it 'calls Result' do
      expect(PaymentAdapter::GatewayAdapter::Result)
        .to receive(:new)
        .with(amount, currency)
        .and_return(result)
        .and_call_original

      charge
    end
  end
end
