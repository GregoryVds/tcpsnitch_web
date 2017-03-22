class StatComputation
	STATS_DEFINITIONS = {
		# Socket
		socket_domains: 		Stat.new(:prop, 'details.domain', 				type: 'socket'),
		socket_types: 			Stat.new(:prop, 'details.type', 					type: 'socket'),
		socket_protocols: 	Stat.new(:prop, 'details.protocol', 			type: 'socket'),
		socket_cloexec: 		Stat.new(:prop, 'details.SOCK_CLOEXEC', 	type: 'socket'),
		socket_nonblock: 		Stat.new(:prop, 'details.SOCK_NONBLOCK', 	type: 'socket'),
		# Getsockopt	
		getsockopt_optname: Stat.new(:prop, 'details.optname', 				type: 'getsockopt'),
		getsockopt_level: 	Stat.new(:prop, 'details.level', 					type: 'getsockopt'),
		setsockopt_optname: Stat.new(:prop, 'details.optname', 				type: 'setsockopt'),
		setsockopt_level: 	Stat.new(:prop, 'details.level', 					type: 'setsockopt'),
		# Fcntl
		fcntl_cmd: 					Stat.new(:prop, 'details.cmd', 						type: 'fcntl'),
		function_calls: 		Stat.new(:prop, 'type'),
		# CDF
		read_bytes:					Stat.new(:cdf, 'details.bytes', 					type: 'read'),	
		recv_bytes: 				Stat.new(:cdf, 'details.bytes', 					type: 'recv')	
	}

	def initialize(stat_name, trace_filters)
		raise "Invalid stat_name: #{stat_name}" unless STATS_DEFINITIONS.has_key?(stat_name)
		@stat = STATS_DEFINITIONS[stat_name]
		@where = @stat.event_filters.merge(trace_filters)
	end

	def compute
		if @stat.type == :prop then
			Event.count_by_val(@stat.node, @where) 
		elsif @stat.type == :cdf then
		 	cdf(Event.vals(@stat.node, @where))
		end
	end

	def cdf(sorted_val)
		sorted_val.map do |el|
			pc = ((sorted_val.rindex { |v| v <= el } || -1.0) + 1.0) / sorted_val.size * 100.0
			[el, pc]
		end.uniq
  end
end

