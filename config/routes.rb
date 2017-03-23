Rails.application.routes.draw do
  devise_for :admin_users, ActiveAdmin::Devise.config
  ActiveAdmin.routes(self)
  root 'pages#home'

  controller :pages do
    get :about
  end

  resources :app_traces
  resources :socket_traces
  resources :process_traces

  require 'sidekiq/web'
  mount Sidekiq::Web, at: '/jobs'
end
