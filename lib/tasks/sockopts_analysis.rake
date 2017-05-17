require 'descriptive_statistics'

os          = ENV['os']
socket_type = ENV['socket_type'] ? ENV['socket_type'] : nil
remote_con  = ENV['remote_con'] ? ENV['remote_con'] : nil
target      = ENV['target'] ? ENV['target'] : nil

target = target.nil? ? [:getsockopt, :setsockopt] : [target]

def f(val, x)
  val.to_s.ljust(x)
end

namespace :custom do
  desc 'Sockopts analysis'
  task :sockopts_analysis => :environment do
    scope = SocketTrace.joins(:app_trace).where(app_traces: {os: os})
    scope = scope.where(socket_type: socket_type) unless socket_type.nil?
    scope = scope.where(remote_con: remote_con.eql?("true")) unless remote_con.nil?

    traces_with_sockopts = 0
    sockopts_count = Hash.new{0}
    positions = Hash.new {|h,k| h[k]=[]}
    occurences = Hash.new {|h,k| h[k]=[]}
    sockopts_traces_count = Hash.new{0}

    scope.each do |socket_trace|
      sockopts = Event.where(socket_trace_id: socket_trace.id, :type.in => target).pluck(:index, 'details.optname')
      next if sockopts.empty?
      trace_sockopts = Hash.new{0}
      sockopts.each do |index, sockopt_hash|
        sockopt = sockopt_hash['optname']
        sockopts_traces_count[sockopt] += 1 if !trace_sockopts.has_key?(sockopt)
        trace_sockopts[sockopt] +=1
        sockopts_count[sockopt] +=1
        positions[sockopt].push(index/socket_trace.events_count.to_f)
      end
      trace_sockopts.each do |k,v|
        occurences[k].push(v)
      end
    end

    puts "Target: #{target}"
    puts "Os: #{os.nil? ? "all" : os}"
    puts "Socket type: #{socket_type.nil? ? "all" : socket_type}"
    puts "Remote connections: #{remote_con.nil? ? "all" : remote_con}"

    header = f("SOCKOPT",20) + f("COUNT",10) + f("SOCKETS",10)
    ["OCC", "POS"].each do |metric|
      ["MEAN", "STDEV", "MODE", "RANGE", "Q1", "Q2", "Q3"].each do |stat|
        header += f("#{metric}_#{stat}", 10)
      end
    end
    puts header

    sockopts_count.each do |sockopt, count|
      traces_count = sockopts_traces_count[sockopt]
      line = f(sockopt, 20)
      line += f(count,10)
      line += f(traces_count,10)

      [occurences, positions].each do |dic|
        [:mean, :standard_deviation, :mode, :range,
         [:percentile,25], [:percentile,50], [:percentile,75]].each do |meth, param|
          if param.nil?
            val = dic[sockopt].send(meth)
          else
            val = dic[sockopt].send(meth, param)
          end
          line += f(val.round(2),10)
        end
      end
      puts line
    end
  end
end

