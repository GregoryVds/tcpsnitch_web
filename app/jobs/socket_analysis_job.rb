class SocketAnalysisJob < ActiveJob::Base
  queue_as :xxlow

  def perform(analysable_type, analysable_id)
    Analysis.compute(analysable_type, analysable_id)
  end
end
