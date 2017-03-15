class AppTraceStat
	include Mongoid::Document
	
	after_create :set_stats_computed

	field :app_trace_id, type: Integer
	field :socket_types, type: Hash

	def app_trace
		@app_trace ||= AppTrace.find(app_trace_id)
	end

	def set_stats_computed
		app_trace.update_column(:stats_computed, true)
	end

	def self.compute(app_trace_id)
		self.create(
			app_trace_id: app_trace_id,
			socket_types: socket_types(app_trace_id)
		)
	end

	def self.socket_types(trace_id) 
		Event.collection.aggregate([ 
			{"$match": { app_trace_id: trace_id, type: "socket" }}, 
			{"$sortByCount": "$details.type"}
		]).map do |r|
			[r["_id"], r["count"]]
		end.to_h
	end
end
