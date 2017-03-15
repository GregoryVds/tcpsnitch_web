class AppTraceStat
	include Mongoid::Document
	
	STATS = [
		:socket_domains,
		:socket_types,
		:socket_protocols
	]

	after_create :set_stats_computed

	field :app_trace_id, type: Integer

	STATS.each do |stat|
		field stat, type: Array
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
			attr[stat] = self.send(stat, app_trace_id) 
		end
		puts attr
		create(attr)
	end

	def self.socket_domains(id) 
		Event.proportions('details.domain', app_trace_id: id, type: 'socket')
	end

	def self.socket_types(id) 
		Event.proportions('details.type', app_trace_id: id, type: 'socket')
	end
	
	def self.socket_protocols(id) 
		Event.proportions('details.protocol', app_trace_id: id, type: 'socket')
	end

end
