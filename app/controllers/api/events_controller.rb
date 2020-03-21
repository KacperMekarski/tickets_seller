# frozen_string_literal: true

class Api::EventsController < ApplicationController
  rescue_from ActiveRecord::RecordNotFound, with: :render_event_not_found

  before_action :find_event, only: %i[show_basic_info show_available_tickets]

  class_attribute :json_basic_info
  class_attribute :json_available_tickets
  class_attribute :json_events

  self.json_basic_info = {
    only: %i[id name location happens_at ticket_price]
  }

  self.json_available_tickets = {
    only: %i[id tickets_available]
  }

  self.json_events = {
    only: %i[id name location happens_at ticket_price tickets_available]
  }

  def show_basic_info
    render json: { event: @event.as_json(json_basic_info) }
  end

  def show_available_tickets
    render json: { event: @event.as_json(json_available_tickets) }
  end

  def index
    @events = Event.all
    render json: { events: @events.as_json(json_events) }
  end

  private

  def find_event
    @event = Event.find(params[:id])
  end

  def render_event_not_found(error)
    render json: error, status: 404
  end
end
