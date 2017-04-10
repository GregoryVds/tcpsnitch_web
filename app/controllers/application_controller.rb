class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception

  def default_url_options(options={})
    { protocol: (Rails.env.production? ? :https : :http) }
  end
end
