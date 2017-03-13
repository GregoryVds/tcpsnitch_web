Rails.application.routes.draw do
  root 'home#index'
	
	resources :traces

	require 'sidekiq/web'
	mount Sidekiq::Web, at: '/jobs'
end
