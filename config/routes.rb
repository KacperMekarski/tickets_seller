# frozen_string_literal: true

Rails.application.routes.draw do
  namespace :api do
    get '/events/:id/inform', to: 'events#show_basic_info'
    get '/events/:id/available_tickets', to: 'events#show_available_tickets'
    post '/events/:event_id/purchase_tickets', to: 'payments#call'
  end
end
