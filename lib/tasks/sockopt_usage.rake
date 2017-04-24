connectivity_filter = ENV['con']
os_filter = ENV['os']
node = ENV['node'] ? ENV['node'] : 'optname'

namespace :custom do
  desc 'Extract apps using each sockopt/level'
  task :sockopt_usage => :environment do
    Dataset.get.analysis[:measures]["getsockopt(), setsockopt() #{node}"].each do |val, count|
      ids = Event.in(type: [:getsockopt, :setsockopt]).where("details.#{node}" => val).pluck(:app_trace_id).uniq
      scope = AppTrace.where(id: ids)
      scope = scope.where(connectivity: connectivity_filter) if connectivity_filter
      scope = scope.where(os: os_filter) if os_filter
      apps = scope.pluck(:app).uniq
      puts "#{val} (##{count}):"
      puts apps.join(', ')
    end
  end
end
