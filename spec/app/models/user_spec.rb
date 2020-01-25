# frozen_string_literal: true

require 'rails_helper'

RSpec.describe User, type: :model do
  describe 'validations' do
    subject(:user) { create(:user) }

    it { is_expected.to validate_presence_of(:email) }
    it { is_expected.to validate_uniqueness_of(:email) }
    it { is_expected.to allow_value('example@email.com').for(:email) }
    it { is_expected.not_to allow_value('example@email').for(:email) }
    it { is_expected.not_to allow_value('example$email.com').for(:email) }

    it { is_expected.to validate_presence_of(:full_name) }
  end

  describe 'relations' do
    it { is_expected.to have_many(:payments) }
    # it { is_expected.to have_many(:tickets).through(:payments) }
  end
end
