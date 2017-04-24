connectivity_filter = ENV['con']
os_filter = ENV['os']

namespace :custom do
  desc 'Extract apps using each ioctl'
  task :ioctl_usage => :environment do
    Dataset.get.analysis[:measures]['ioctl() requests'].each do |ioctl, count|
      ids = Event.in(type: [:ioctl]).where('details.request' => ioctl).pluck(:app_trace_id).uniq
      scope = AppTrace.where(id: ids)
      scope = scope.where(connectivity: connectivity_filter) if connectivity_filter
      scope = scope.where(os: os_filter) if os_filter
      apps = AppTrace.where(id: ids).pluck(:app).uniq
      puts "#{ioctl} (##{count}):"
      puts apps.join(', ')
    end
  end
end
