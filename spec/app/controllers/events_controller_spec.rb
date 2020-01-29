# frozen_string_literal: true

require 'rails_helper'
require 'json'

RSpec.describe Api::EventsController, type: :controller do
  describe 'GET #show_basic_info' do
    before { get(:show_basic_info, params: { id: id }) }
    let!(:event) { create(:event) }

    context 'when event is found' do
      let(:id) { event.id }
      let(:response_data) { JSON.parse(response.body)['event'] }

      it { expect(response_data['id']).to eq(event.id) }
      it { expect(response_data['name']).to eq(event.name) }
      it { expect(response_data['location']).to eq(event.location) }
      it { expect(response_data['happens_at']).to eq(event.happens_at.as_json) }
      it { expect(response_data['ticket_price']).to eq(event.ticket_price) }
      it { expect(response.status).to eq(200) }
    end

    context 'when event is not found' do
      let(:id) { 12_345 }
      let(:response_data) { JSON.parse(response.body) }

      it { expect(response_data).to eq("Couldn't find Event with 'id'=#{id}") }
      it { expect(response.status).to eq(404) }
    end
  end

  describe 'GET #show_available_tickets' do
    before { get(:show_available_tickets, params: { id: id }) }
    let!(:event) { create(:event) }

    context 'when event is found' do
      let(:id) { event.id }
      let(:response_data) { JSON.parse(response.body)['event'] }

      it { expect(response_data['tickets_available']).to eq(event.tickets_available) }
      it { expect(response.status).to eq(200) }
    end

    context 'when event is not found' do
      let(:id) { 12_345 }
      let(:response_data) { JSON.parse(response.body) }

      it { expect(response_data).to eq("Couldn't find Event with 'id'=#{id}") }
      it { expect(response.status).to eq(404) }
    end
  end

  describe 'GET #index' do
    subject(:get_index) { get(:index) }
    let(:response_data) { JSON.parse(response.body)['events'] }

    context 'when events exist' do
      let!(:event) { create_list(:event, 10) }
      it 'returns events' do
        get_index
        expect(response_data.count).to eq 10
      end
      it 'has status 200' do
        get_index
        expect(response.status).to eq(200)
      end
    end

    context 'when there is no event' do
      it 'returns events' do
        get_index
        expect(response_data.count).to eq 0
      end
      it 'has status 200' do
        get_index
        expect(response.status).to eq(200)
      end
    end
  end

  describe 'callbacks' do
    it { should use_before_action(:find_event) }
  end

  describe 'rescue_from' do
    it { should rescue_from(ActiveRecord::RecordNotFound).with(:render_event_not_found) }
  end
end
