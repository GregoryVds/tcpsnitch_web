class DatasetSegment
  include Analysable

  SEGMENTS_FILTERS = {
    global:         {fake_call: false},
    sanitized:      {fake_call: false, network_specialized_app: false},
    android:        {fake_call: false, network_specialized_app: false, os: AppTrace.os[:android]},
    linux:          {fake_call: false, network_specialized_app: false, os: AppTrace.os[:linux]},
    udp:            {fake_call: false, network_specialized_app: false, socket_type: SocketTrace.socket_types[:SOCK_DGRAM]},
    tcp:            {fake_call: false, network_specialized_app: false, socket_type: SocketTrace.socket_types[:SOCK_STREAM]},
    android_remote: {fake_call: false, network_specialized_app: false, os: AppTrace.os[:android], remote_con: true},
    android_ipv4:   {fake_call: false, network_specialized_app: false, os: AppTrace.os[:android], socket_domain: SocketTrace.socket_domains[:AF_INET]},
    android_ipv6:   {fake_call: false, network_specialized_app: false, os: AppTrace.os[:android], socket_domain: SocketTrace.socket_domains[:AF_INET6]},
    android_udp:    {fake_call: false, network_specialized_app: false, os: AppTrace.os[:android], socket_type: SocketTrace.socket_types[:SOCK_DGRAM]},
    android_tcp:    {fake_call: false, network_specialized_app: false, os: AppTrace.os[:android], socket_type: SocketTrace.socket_types[:SOCK_STREAM]}
  }

  SEGMENTS = SEGMENTS_FILTERS.keys

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
