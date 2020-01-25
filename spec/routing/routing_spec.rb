# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Routing', type: :routing do
  it { is_expected.to route(:get, '/api/events/1/inform').to(controller: "api/events", action: :inform, id: 1) }
  it { is_expected.to route(:get, '/api/events/1/available_tickets').to(controller: "api/events", action: :calculate_available_tickets, id: 1) }
  it { is_expected.to route(:post, '/api/events/1/purchase_tickets').to(controller: "api/payments", action: :call, event_id: 1) }
end
