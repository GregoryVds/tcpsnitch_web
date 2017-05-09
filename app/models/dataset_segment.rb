class DatasetSegment
  include Analysable

  SEGMENTS = [:global, :sanitized, :android, :linux, :ipv4, :ipv6, :udp, :tcp]

  SEGMENTS_FILTERS = {
    global:     {fake_call: false},
    sanitized:  {fake_call: false, network_specialized_app: false, remote_con: true},
    android:    {fake_call: false, network_specialized_app: false, remote_con: true, os: AppTrace.os[:android]},
    linux:      {fake_call: false, network_specialized_app: false, remote_con: true, os: AppTrace.os[:linux]},
    ipv4:       {fake_call: false, network_specialized_app: false, remote_con: true, socket_domain: SocketTrace.socket_domains[:AF_INET]},
    ipv6:       {fake_call: false, network_specialized_app: false, remote_con: true, socket_domain: SocketTrace.socket_domains[:AF_INET6]},
    udp:        {fake_call: false, network_specialized_app: false, remote_con: true, socket_type: SocketTrace.socket_types[:SOCK_DGRAM]},
    tcp:        {fake_call: false, network_specialized_app: false, remote_con: true, socket_type: SocketTrace.socket_types[:SOCK_STREAM]},
  }

  def os
    nil
  end

  def initialize(segment_type=:global)
    @segment_type = segment_type.to_sym
  end

  def events_filter
    DatasetSegment::SEGMENTS_FILTERS[@segment_type]
  end

  def analysable_type
    :dataset
  end

  def analysable_id # Create unique id based on os & con
    DatasetSegment::SEGMENTS.index(@segment_type)
  end

  def self.schedule_all_analysis
    SEGMENTS.each do |segment|
      DatasetAnalysisJob.perform_later(segment.to_s)
    end
  end
end
