class SocketTrace < ActiveRecord::Base
  include Analysable
  include Trace

  enum socket_type: {SOCK_DGRAM: 0, SOCK_STREAM: 1, SOCK_RAW: 2}
  enum socket_domain: {AF_PACKET: 0, AF_INET: 1, AF_INET6: 2}

  belongs_to :app_trace, inverse_of: :socket_traces, counter_cache: true
  belongs_to :process_trace, inverse_of: :socket_traces, counter_cache: true

  validates :process_trace, :app_trace, presence: true
  # At creation time, events are not yet processed
  validates :socket_type, :events_count, presence: true, on: :update

  # Analysable
  delegate :os, to: :process_trace
  delegate :connectivity, to: :process_trace

  def to_s
    "Socket trace ##{id}"
  end

  def long_name
    "#{socket_type} socket opened by process #{process_trace.name}"
  end
end
