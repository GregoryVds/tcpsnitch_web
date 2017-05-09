os          = ENV['os']
target      = ENV['target'] ? ENV['target'] : 'app_trace'
subject     = ENV['subject'] ? ENV['subject'] : 'functions'

stat = if subject.eql?('functions')
  "Functions calls"
elsif subject.eql?('sockopts')
  "Sockopts optname args"
elsif subject.eql?('ioctls')
  "ioctl() requests args"
else
  raise "subject error"
end

namespace :custom do
  desc 'Count for each socket trace footprint'
  task :socket_traces_footprint => :environment do
    footprints = Hash.new{0}

    scope = Analysis.where(analysable_type: target)
    scope = scope.where(os: AppTrace.os[os]) unless os.nil?

    if target.eql?('app_trace') then
      footprints_per_app = Hash.new{[]}

      scope.all.each do |analysis|
        app = AppTrace.find(analysis.analysable_id).app
        stats = analysis[:measures][stat]
        next if stats.nil?
        footprint = stats.map(&:first).sort
        footprints_per_app[app] += footprint
      end

      total = footprints_per_app.size
      footprints_per_app.values.each do |footprint|
        footprints[footprint.uniq.join(',')] += 1
      end
    else
      scope = Analysis.where(analysable_type: target)
      scope = scope.where(os: AppTrace.os[os]) unless os.nil?
      total = scope.count

      scope.all.each do |analysis|
        stats = analysis[:measures][stat]
        next if stats.nil?
        footprint = stats.map(&:first).sort
        footprints[footprint.join(',')] += 1
      end
    end

    puts "#{subject.capitalize} usage by #{target}"
    puts "Os: #{os.nil? ? "all" : os}"
    puts "Totat: #{total}"

    footprints.sort_by{|k,v| v}.reverse.each do |footprint, count|
      puts "#{'%.3f' % (count/total.to_f)}%: #{footprint.split(',')}"
    end
  end
end
