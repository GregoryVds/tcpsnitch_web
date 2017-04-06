class SocketTrace < ActiveRecord::Base
  include Trace

  enum socket_type: {SOCK_DGRAM: 0, SOCK_STREAM: 1}

  belongs_to :app_trace, inverse_of: :socket_traces, counter_cache: true
  belongs_to :process_trace, inverse_of: :socket_traces, counter_cache: true

  validates :process_trace, :app_trace, presence: true
  # At creation time, events are not yet processed
  validates :socket_type, :events_count, presence: true, on: :update

  def to_s
    "Socket trace ##{id}"
  end
end
