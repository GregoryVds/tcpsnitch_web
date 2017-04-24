connectivity_filter = ENV['con']
os_filter = ENV['os']
node = ENV['node'] ? ENV['node'] : 'optname'

namespace :custom do
  desc 'Extract apps using each sockopt/level'
  task :sockopt_usage => :environment do
    DatasetAnalysis.get(os_filter,connectivity_filter)[:measures]["getsockopt(), setsockopt() #{node}"].each do |val, count|
      ids = Event.in(type: [:getsockopt, :setsockopt]).where("details.#{node}" => val).pluck(:app_trace_id).uniq
      apps = AppTrace.where(id: ids).pluck(:app).uniq

      # Apps matching filters
      scope = AppTrace
      scope = scope.where(connectivity: connectivity_filter) unless connectivity_filter.nil?
      scope = scope.where(os: os_filter) unless os_filter.nil?
      total_apps = scope.pluck(:app).uniq.count

      puts "#{val} (##{count} calls):"
      puts "#{apps.count}/#{total_apps} apps: #{apps.join(', ')}"
    end
  end
end
