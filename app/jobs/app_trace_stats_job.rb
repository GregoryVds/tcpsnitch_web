class AppTraceStatsJob < ActiveJob::Base
	queue_as :default

	def perform(app_trace_id)
		AppTraceStat.create(app_trace_id: app_trace_id)
	end

	after_perform do |job|
		app_trace = AppTrace.find(job.arguments.first)	
		app_trace.stats_computed = true
		app_trace.save
	end
end
