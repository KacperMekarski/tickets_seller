# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Payment, type: :model do
  describe 'relations' do
    subject(:payment) { create(:payment) }

    it { is_expected.to belong_to(:user) }
    it { is_expected.to belong_to(:event) }
    it { is_expected.to have_many(:tickets) }
  end
end
