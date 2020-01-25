# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Event, type: :model do
  describe 'validations' do
    subject(:event) { create(:event) }

    it { is_expected.to validate_presence_of(:name) }
    it { is_expected.to validate_presence_of(:location) }
    it { is_expected.to validate_presence_of(:happens_at) }
    it { is_expected.to validate_presence_of(:ticket_price) }
    it { is_expected.to validate_presence_of(:tickets_available) }
    it { should validate_numericality_of(:ticket_price).only_integer.is_greater_than_or_equal_to(1) }
    it { should validate_numericality_of(:tickets_available).only_integer.is_greater_than_or_equal_to(0) }
  end

  describe 'relations' do
    it { is_expected.to have_many(:payments) }
    it { is_expected.to have_many(:purchased_tickets).through(:payments).class_name('Ticket') }
  end
end
