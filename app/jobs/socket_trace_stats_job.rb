class SocketTraceStatsJob < ActiveJob::Base
	queue_as :default

	def perform(socket_trace_id)
		SocketTraceStat.compute(socket_trace_id)
	end
end
