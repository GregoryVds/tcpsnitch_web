class AppTraceStat
	include Mongoid::Document

	STATS = [
		# Socket
		Stat.prop(:socket_domains, 'details.domain', type: 'socket'),
		Stat.prop(:socket_types, 'details.type', type: 'socket'),
		Stat.prop(:socket_protocols, 'details.protocol', type: 'socket'),
		Stat.prop(:socket_cloexec, 'details.SOCK_CLOEXEC', type: 'socket'),
		Stat.prop(:socket_cloexec, 'details.SOCK_NONBLOCK', type: 'socket'),
		# Getsockopt	
		Stat.prop(:getsockopt_optname, 'details.optname', type: 'getsockopt'),
		Stat.prop(:getsockopt_level, 'details.level', type: 'getsockopt'),
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

	field :app_trace_id, type: Integer

	STATS.each do |stat|
		field stat.db_name, type: Array
	end

	def app_trace
		@app_trace ||= AppTrace.find(app_trace_id)
	end

	def set_stats_computed
		app_trace.update_column(:stats_computed, true)
	end

	def self.compute(app_trace_id)
		attr = {app_trace_id: app_trace_id} 
		STATS.each do |stat| 
			attr[stat.db_name] = 
				StatComputation.new(stat, {app_trace_id: app_trace_id}).compute
		end
		create(attr)
	end
end
