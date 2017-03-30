require_relative 'boot'

require 'rails/all'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module TcpsnitchWeb
  class Application < Rails::Application
    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.
    config.generators do |g|
      g.orm :active_record
    end

    config.active_job.queue_adapter = :sidekiq
    config.web_console.whitelisted_ips = '192.168.99.0/24'
    config.autoload_paths << "#{Rails.root}/lib"
  end
end

