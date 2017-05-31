class AppTrace < ActiveRecord::Base
  include Archive
  include Analysable
  include Trace

  enum connectivity: {
    wifi: 0,
    lte: 1,
    #ethernet: 2,
    wifi_shutdown_to_lte: 3,
    wifi_loss_to_lte: 4,
    wifi_rate_limited: 5
  }

  enum os: {linux: 0, android: 1}

  has_many :process_traces, -> { order :id }, inverse_of: :app_trace, dependent: :destroy
  has_many :socket_traces, inverse_of: :app_trace

  before_save :update_events_os, if: :os_changed?
  before_save :update_events_connectivity, if: :connectivity_changed?
  before_save :update_network_specialized_app, if: :network_specialized_app_changed?

  def update_events_os
    events.update_all(os: os)
  end

  def update_events_connectivity
    events.update_all(connectivity: connectivity)
  end

  def update_network_specialized_app
    events.update_all(network_specialized_app: network_specialized_app)
  end

  def os_int
    AppTrace.os[os]
  end

  def connectivity_int
    AppTrace.connectivities[connectivity]
  end

  def to_s
    "App trace ##{id}"
  end

  def long_name
    "#{app.capitalize} on #{os.capitalize}"
  end
end
