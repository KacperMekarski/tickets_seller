# frozen_string_literal: true

Rails.application.routes.draw do
  namespace :api do
    get '/events/:id/inform', to: 'events#show_basic_info'
    get '/events/:id/available_tickets', to: 'events#show_available_tickets'
    get '/events', to: 'events#index'
    post '/events/:event_id/payments', to: 'payments#create'
  end
end
