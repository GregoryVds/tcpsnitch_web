namespace :custom do
  desc 'Extract apps using each sockopt level'
  task :sockopt_level_usage => :environment do
    Dataset.get.analysis[:measures]['getsockopt(), setsockopt() level'].each do |level, count|
      ids = Event.in(type: [:getsockopt, :setsockopt]).where('details.level' => level).pluck(:app_trace_id).uniq
      apps = AppTrace.where(id: ids).pluck(:app).uniq
      puts "#{level} (##{count}):"
      puts apps.join(', ')
    end
  end
end
