class SocketAnalysisJob < ActiveJob::Base
  queue_as :xxlow

  def perform(id)
    SocketTrace.find(id).update_analysis
  end
end
