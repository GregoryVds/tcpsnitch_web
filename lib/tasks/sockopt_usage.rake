namespace :custom do
  desc 'Extract apps using each sockopt'
  task :sockopt_usage => :environment do
    Dataset.get.analysis[:measures]['getsockopt(), setsockopt() optname'].each do |optname, count|
      ids = Event.in(type: [:getsockopt, :setsockopt]).where('details.optname' => optname).pluck(:app_trace_id).uniq
      apps = AppTrace.where(id: ids).pluck(:app).uniq
      puts "#{optname} (##{count}):"
      puts apps.join(', ')
    end
  end
end
