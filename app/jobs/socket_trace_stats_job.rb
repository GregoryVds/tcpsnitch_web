class SocketTraceStatsJob < ActiveJob::Base
	queue_as :default

	def perform(socket_trace_id)
		SocketTraceStat.create(socket_trace_id: socket_trace_id)
	end

	after_perform do |job|
		socket_trace = SocketTrace.find(job.arguments.first)	
		socket_trace.stats_computed = true
		socket_trace.save
	end
end
