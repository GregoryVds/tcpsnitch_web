os          = ENV['os']
target      = ENV['target'] ? ENV['target'] : 'app_trace'
subject     = ENV['subject'] ? ENV['subject'] : 'functions'
inc_subsets = ENV['inc_subsets'] ? true : false
socket_type = ENV['socket_type'] ? ENV['socket_type'] : nil
remote_con  = ENV['remote_con'] ? ENV['remote_con'] : nil

stat = if subject.eql?('functions') then "Functions calls"
    elsif subject.eql?('sockopts')  then "Sockopts optname args"
    elsif subject.eql?('ioctls')    then "ioctl() requests args"
    else raise "subject error"
    end

namespace :custom do
  desc 'Footprint analysis'
  task :footprint => :environment do
    footprints = Hash.new{0}

    scope = Analysis.where(analysable_type: target)
    scope = scope.where(os: AppTrace.os[os]) unless os.nil?
    scope = scope.where(socket_type: SocketTrace.socket_types[socket_type]) unless socket_type.nil?
    scope = scope.where(remote_con: remote_con.eql?("true")) unless remote_con.nil?

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
        footprints[footprint.uniq.sort.join(',')] += 1
      end
    else
      scope.all.each do |analysis|
        stats = analysis[:measures][stat]
        next if stats.nil?
        footprint = stats.map(&:first).sort
        footprints[footprint.join(',')] += 1
      end

      total = scope.count
    end

    if inc_subsets
      footprints_clone = footprints.clone
      footprints.each do |footprint1, count1|
        footprints.each do |footprint2, count2|
          next if footprint1.eql?(footprint2)
          footprints_clone[footprint1] += count2 if (footprint2.split(',')-footprint1.split(',')).empty? # If 2 is subset of 1
        end
      end
      footprints = footprints_clone
    end

    puts "#{subject.capitalize} usage (% of #{target})"
    puts "Os: #{os.nil? ? "all" : os}"
    puts "Socket type: #{socket_type.nil? ? "all" : socket_type}"
    puts "Remote connections: #{remote_con.nil? ? "all" : remote_con}"
    puts "Include subsets: #{inc_subsets}"
    puts "Total: #{total}"

    footprints.sort_by{|k,v| v}.reverse.each do |footprint, count|
      puts "#{'%.4f' % (count/total.to_f)}: #{footprint.split(',')}"
    end
  end
end
