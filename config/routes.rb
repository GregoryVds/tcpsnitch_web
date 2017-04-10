Rails.application.routes.draw do
  default_url_options protocol: (Rails.env.production? ? :https : :http)
  devise_for :admin_users, ActiveAdmin::Devise.config
  ActiveAdmin.routes(self)
  root 'app_traces#index'

  controller :pages do
    get :about
  end

  resources :app_traces
  resources :process_traces
  resources :socket_traces do
    resources :events
  end

  require 'sidekiq/web'
  authenticate do
    mount Sidekiq::Web, at: '/jobs'
  end

end
