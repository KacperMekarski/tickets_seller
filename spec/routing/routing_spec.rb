# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Routing', type: :routing do
  it { is_expected.to route(:get, '/api/events/1/inform').to(controller: 'api/events', action: :show_basic_info, id: 1) }
  it { is_expected.to route(:get, '/api/events/1/available_tickets').to(controller: 'api/events', action: :show_available_tickets, id: 1) }
  it { is_expected.to route(:get, '/api/events').to(controller: 'api/events', action: :index) }
  it { is_expected.to route(:post, '/api/events/1/payments').to(controller: 'api/payments', action: :create, event_id: 1) }
end
