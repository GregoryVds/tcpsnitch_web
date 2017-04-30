os = ENV['os']

namespace :custom do
  desc 'Count for each socket trace footprint'
  task :socket_traces_footprint => :environment do
    footprints = Hash.new{0}

    scope = Analysis.where(analysable_type: :socket_trace)
    scope = scope.where(os: os) unless os.nil?

    scope.all.each do |analysis|
      calls = analysis[:measures]["Functions calls"]
      next if calls.nil?
      footprint = calls.map(&:first).sort
      footprints[footprint.join(',')] += 1
    end
    footprints.sort_by{|k,v| v}.reverse.each do |footprint, count|
      puts "##{count}: #{footprint.split(',')}"
    end
  end
end
