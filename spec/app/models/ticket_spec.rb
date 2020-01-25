# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Ticket, type: :model do

  describe 'relations' do
    it { is_expected.to belong_to(:payment) }
    it { is_expected.to belong_to(:event) }
  end
end
