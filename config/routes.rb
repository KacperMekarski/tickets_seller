# frozen_string_literal: true

Rails.application.routes.draw do
  namespace :api do
    get '/events/:id/inform', to: 'events#inform'
    get '/events/:id/available_tickets', to: 'events#calculate_available_tickets'
    post '/events/:event_id/purchase_tickets', to: 'payments#call'
  end
end
