# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Payment, type: :model do
  describe 'validations' do
    subject(:payment) { create(:payment) }

    it { is_expected.to validate_presence_of(:paid_amount) }
    it { should validate_numericality_of(:paid_amount).only_integer.is_greater_than_or_equal_to(1) }
  end

  describe 'relations' do
    it { is_expected.to belong_to(:user) }
    it { is_expected.to belong_to(:event) }

    it { is_expected.to have_many(:tickets) }
  end
end
