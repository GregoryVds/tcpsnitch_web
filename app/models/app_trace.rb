class AppTrace < ActiveRecord::Base
  include Archive
  include Trace

  enum connectivity: {wifi: 0, lte: 1, ethernet: 2}
  enum os: {linux: 0, android: 1, darwin: 2}

  has_many :process_traces, -> { order :id }, inverse_of: :app_trace, dependent: :destroy
  has_many :socket_traces, inverse_of: :app_trace

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
