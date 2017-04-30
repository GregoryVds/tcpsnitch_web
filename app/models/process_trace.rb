class ProcessTrace < ActiveRecord::Base
  include Analysable
  include Trace

  belongs_to :app_trace, inverse_of: :process_traces, counter_cache: true
  has_many :socket_traces, inverse_of: :process_trace, dependent: :destroy

  validates :app_trace, :name, presence: true

  # Analysable
  delegate :os, to: :app_trace
  delegate :connectivity, to: :app_trace


  def to_s
    "Process trace ##{id}"
  end

  def long_name
    "#{name.capitalize} process spawned by #{app_trace.app.capitalize} on #{app_trace.os.capitalize}"
  end
end
