class TraceImportJob < ActiveJob::Base
	queue_as :default

	def perform(trace_id)
		trace = Trace.find(trace_id)
		trace.processed = true
		trace.save!
	end
end
