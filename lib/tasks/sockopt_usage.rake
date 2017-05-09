connectivity  = ENV['con']
os            = ENV['os']
node          = ENV['node'] ? ENV['node'] : 'optname'
exclude       = ENV['exclude'] ? ENV['exclude'].split(',') : nil

namespace :custom do
  desc 'Extract apps using each sockopt/level'
  task :sockopt_usage => :environment do
    DatasetAnalysis.get(os,connectivity)[:measures]["getsockopt(), setsockopt() #{node}"].each do |val, count|
      # Excluded apps
      excluded_apps = AppTrace.where(app: exclude).pluck(:id)

      # Events matching filters
      ev_scope = Event.in(type: [:getsockopt, :setsockopt]).not_in(app_trace_id: excluded_apps)
      ev_scope = ev_scope.where(connectivity: connectivity) unless connectivity.nil?
      ev_scope = ev_scope.where(os: os) unless os.nil?
      ev_scope = ev_scope.where("details.#{node}" => val)
      apps = AppTrace.where(id: ev_scope.pluck(:app_trace_id).uniq).pluck(:app).uniq

      # Apps matching filters
      scope = AppTrace.where.not(id: excluded_apps)
      scope = scope.where(connectivity: connectivity) unless connectivity.nil?
      scope = scope.where(os: os) unless os.nil?
      total_apps = scope.pluck(:app).uniq.count

      puts "#{val} (##{count} calls):"
      puts "#{apps.count}/#{total_apps} apps: #{apps.join(', ')}"
    end
  end
end
