namespace :custom do
  desc 'Extract apps using each ioctl'
  task :ioctl_usage => :environment do
    Dataset.get.analysis[:measures]['ioctl() requests'].each do |ioctl, count|
      ids = Event.in(type: [:ioctl]).where('details.request' => ioctl).pluck(:app_trace_id).uniq
      apps = AppTrace.where(id: ids).pluck(:app).uniq
      puts "#{ioctl} (##{count}):"
      puts apps.join(', ')
    end
  end
end
