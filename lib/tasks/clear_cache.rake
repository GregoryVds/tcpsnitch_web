namespace :custom do
  desc 'Clear Rails cache'
  task :clear_cache => :environment do
    Rails.cache.clear
  end
end
