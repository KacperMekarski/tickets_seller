# frozen_string_literal: true

require "rails_helper"
require 'json'

RSpec.describe Api::EventsController, type: :controller do
  describe 'GET #inform' do
    before { get(:inform, params: { id: id }) }
    let!(:event) { create(:event) }

    context 'when event is found' do
      let(:id) { event.id }
      let(:response_data) { JSON.parse(response.body)["event"] }

      it { expect(response_data["id"]).to eq(event.id) }
      it { expect(response_data["name"]).to eq(event.name) }
      it { expect(response_data["location"]).to eq(event.location) }
      it { expect(DateTime.parse( response_data["happens_at"] )).to eq(event.happens_at) }
      it { expect(response_data["ticket_price"]).to eq(event.ticket_price) }
      it { expect(response.status).to eq(200) }
    end

    context 'when event is not found' do
      let(:id) { 12345 }
      let(:response_data) { JSON.parse(response.body) }

      it { expect(response_data).to eq("Couldn't find Event with 'id'=#{id}") }
      it { expect(response.status).to eq(404) }
    end
  end

  describe 'GET #calculate_available_tickets' do
    before { get(:calculate_available_tickets, params: { id: id }) }
    let!(:event) { create(:event) }

    context 'when event is found' do
      let(:id) { event.id }
      let(:response_data) { JSON.parse(response.body)["event"] }

      it { expect(response_data["tickets_available"]).to eq(event.tickets_available) }
      it { expect(response.status).to eq(200) }
    end

    context 'when event is not found' do
      let(:id) { 12345 }
      let(:response_data) { JSON.parse(response.body) }

      it { expect(response_data).to eq("Couldn't find Event with 'id'=#{id}") }
      it { expect(response.status).to eq(404) }
    end
  end

  describe "callbacks" do
    it { should use_before_action(:find_event) }
  end

  describe "rescue_from" do
    it { should rescue_from(ActiveRecord::RecordNotFound).with(:render_event_not_found) }
  end
end

# it { is_expected.to respond_with_content_type(:json) }
# post :create, { :widget => { :name => "Any Name" }, :format => :json }
