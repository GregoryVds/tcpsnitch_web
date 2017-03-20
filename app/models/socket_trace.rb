class SocketTrace < ApplicationRecord
	enum socket_type: {SOCK_DGRAM: 0, SOCK_STREAM: 1}

	belongs_to :app_trace, inverse_of: :socket_traces, counter_cache: true

	before_destroy :destroy_stat

	def stat
		@stat ||= SocketTraceStat.where(socket_trace_id: id).first
	end

	def schedule_stats_computation 
		SocketTraceStatsJob.perform_later(id)
	end

	def destroy_stat
		stat.destroy if stat
	end
end
