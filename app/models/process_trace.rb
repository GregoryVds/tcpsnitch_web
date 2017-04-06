class ProcessTrace < ActiveRecord::Base
  include Trace

  belongs_to :app_trace, inverse_of: :process_traces, counter_cache: true
  has_many :socket_traces, inverse_of: :process_trace, dependent: :destroy

  validates :app_trace, :name, presence: true

  def to_s
    "Trace for process #{name.capitalize} spawned by app #{app_trace.app.capitalize}"
  end
end
