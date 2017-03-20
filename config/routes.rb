Rails.application.routes.draw do
  root 'pages#home'

	controller :pages do
		get :about
	end

	resources :app_traces

	require 'sidekiq/web'
	mount Sidekiq::Web, at: '/jobs'
end
