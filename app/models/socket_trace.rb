class SocketTrace < ActiveRecord::Base
  include Measurable

  STATS = [
    :setsockopt_optname,
    :setsockopt_level,
    :fcntl_cmd,
    :function_calls,
    :read_bytes,
    :recv_bytes
  ]

  enum socket_type: {SOCK_DGRAM: 0, SOCK_STREAM: 1}

  belongs_to :app_trace, inverse_of: :socket_traces, counter_cache: true
  belongs_to :process_trace, inverse_of: :socket_traces, counter_cache: true

  validates :process_trace, :app_trace, presence: true
  # At creation time, events are not yet processed
  validates :socket_type, :events_count, presence: true, on: :update

  def to_s
    "Trace for #{index.ordinalize} socket opened by process #{process_trace.name.capitalize}"
  end
end
