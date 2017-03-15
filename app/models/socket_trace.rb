class SocketTrace < ApplicationRecord
	belongs_to :app_trace, inverse_of: :socket_traces

	enum socket_type: {SOCK_DGRAM: 0, SOCK_STREAM: 1}
end
