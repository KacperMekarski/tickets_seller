# frozen_string_literal: true

require 'rails_helper'
require 'json'

RSpec.describe Payment::Repository do
  describe '.create' do
    subject(:create) do
      described_class.create(attributes)
    end

    let(:attributes) {
      # Źle podajesz instance variable do create jako attributes
      # Payments::CreateForm.new(
      #                           paid_amount: event.ticket_price,
      #                           user_id: user.id,
      #                           event_id: event.id,
      #                           currency: 'EUR',
      #                           tickets_ordered_amount: 1,
      #                         )
    }
    # let!(:event) { create(:event) }

    context 'when data is valid' do
      let(:user) { create(:user) }

      it 'saves tickets to database' do
        expect { subject }.to change { Payment.count }.by(1)
      end
    end

    context 'when data is invalid' do
      let(:user) { nil }

      it 'does not save any ticket to database' do
        expect { subject }.to change { Payment.count }.by(0)
      end
    end
  end
end
