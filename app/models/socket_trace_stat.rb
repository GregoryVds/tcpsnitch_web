class SocketTraceStat
	include Mongoid::Document

	STATS = [
		Stat.prop(:setsockopt_optname, 'details.optname', type: 'setsockopt'),
		Stat.prop(:setsockopt_level, 'details.level', type: 'setsockopt'),
		# Fcntl
		Stat.prop(:fcntl_cmd, 'details.cmd', type: 'fcntl'),
		Stat.prop(:function_calls, 'type'),
		# CDF
		Stat.cdf(:read_bytes, 'details.bytes', type: 'read'),	
		Stat.cdf(:recv_bytes, 'details.bytes', type: 'recv')	
	]

	after_create :set_stats_computed

	field :socket_trace_id, type: Integer

	STATS.each do |stat|
		field stat.db_name, type: Array
	end

	def socket_trace
		@socket_trace ||= SocketTrace.find(socket_trace_id)
	end
	
	def set_stats_computed
		socket_trace.update_column(:stats_computed, true)
	end

	def self.compute(socket_trace_id)
		attr = {socket_trace_id: socket_trace_id}
		STATS.each do |stat| 
			attr[stat.db_name] = 
				StatComputation.new(stat, {socket_trace_id: socket_trace_id}).compute
		end
		create(attr)
	end
end
