Rails.application.routes.draw do
  devise_for :admin_users, ActiveAdmin::Devise.config
  ActiveAdmin.routes(self)
  root 'app_traces#index'

  controller :pages do
    get :about
  end

  resources :app_traces
  resources :socket_traces
  resources :process_traces

  require 'sidekiq/web'
  authenticate do
    mount Sidekiq::Web, at: '/jobs'
  end

end
