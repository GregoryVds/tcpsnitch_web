class SocketTraceStat
	include Mongoid::Document
	field :socket_trace_id, type: Integer

	def socket_trace
		SocketTrace.find(socket_trace_id)
	end
end
