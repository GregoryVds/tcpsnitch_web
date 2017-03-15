class AppTraceStatsJob < ActiveJob::Base
	queue_as :default

	def perform(app_trace_id)
		AppTraceStat.compute(app_trace_id)
	end
end
