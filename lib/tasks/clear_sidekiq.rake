namespace :custom do
  desc 'Clear Sidekiq queues & stats'
  task :clear_sidekiq => :environment do
    Sidekiq::Queue.all.each(&:clear)
    Sidekiq::RetrySet.new.clear
    Sidekiq::ScheduledSet.new.clear
    Sidekiq::Stats.new.reset
  end
end
