Sidekiq.configure_server do |config|
  config.redis = { url: 'redis://localhost:6379', namespace: "tcpsnitch_web_#{Rails.env}" }
end
