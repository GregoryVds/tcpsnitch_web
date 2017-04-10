class AppAnalysisJob < ActiveJob::Base
  queue_as :low

  def perform(analysable_type, analysable_id)
    Analysis.compute(analysable_type, analysable_id)
  end
end
