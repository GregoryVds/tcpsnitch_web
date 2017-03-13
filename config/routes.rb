Rails.application.routes.draw do
  root 'home#index'
	
	resources :datasets

	require 'sidekiq/web'
	mount Sidekiq::Web, at: '/jobs'

end
