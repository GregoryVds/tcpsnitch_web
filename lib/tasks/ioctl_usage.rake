connectivity_filter = ENV['con']
os_filter = ENV['os']

namespace :custom do
  desc 'Extract apps using each ioctl'
  task :ioctl_usage => :environment do
    DatasetAnalysis.get(os_filter, connectivity_filter)[:measures]['ioctl() requests'].each do |ioctl, count|
      ids = Event.in(type: [:ioctl]).where('details.request' => ioctl).pluck(:app_trace_id).uniq
      apps = AppTrace.where(id: ids).pluck(:app).uniq

      # Apps matching filters
      scope = AppTrace
      scope = scope.where(connectivity: connectivity_filter) unless connectivity_filter.nil?
      scope = scope.where(os: os_filter) unless os_filter.nil?
      total_apps = scope.pluck(:app).uniq.count

      puts "#{ioctl} (##{count}):"
      puts "#{apps.count}/#{total_apps} apps: #{apps.join(', ')}"
    end
  end
end
