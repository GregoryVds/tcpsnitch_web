class AppTraceStat
	include Mongoid::Document
	field :app_trace_id, type: Integer

	def app_trace
		AppTrace.find(app_trace_id)
	end
end
