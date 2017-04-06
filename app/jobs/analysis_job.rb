class AnalysisJob < ActiveJob::Base
  queue_as :default

  def perform(analysable_type, analysable_id)
    Analysis.compute(analysable_type, analysable_id)
  end
end
