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
    render json: { model_name => @event.as_json(json_basic_info) }
  end

  def show_available_tickets
    render json: { model_name => @event.as_json(json_available_tickets) }
  end

  def index
    @events = model_class.all
    render json: { model_name_plural => @events.as_json(json_events) }
  end

  private

  def find_event
    @event = model_class.find(params[:id])
  end

  def model_name
    controller_name.singularize
  end

  def model_name_plural
    controller_name
  end

  def model_class
    model_name.classify.constantize
  end

  def render_event_not_found(error)
    render json: error, status: 404
  end
end
