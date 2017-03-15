class SocketTraceStat
	include Mongoid::Document

	after_create :set_stats_computed

	field :socket_trace_id, type: Integer

	def socket_trace
		@socket_trace ||= SocketTrace.find(socket_trace_id)
	end
	
	def set_stats_computed
		socket_trace.update_column(:stats_computed, true)
	end

	def self.compute(socket_trace_id)
		self.create(socket_trace_id: socket_trace_id)
	end
end
