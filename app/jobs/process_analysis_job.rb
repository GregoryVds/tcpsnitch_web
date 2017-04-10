class ProcessAnalysisJob < ActiveJob::Base
  queue_as :xlow

  def perform(analysable_type, analysable_id)
    Analysis.compute(analysable_type, analysable_id)
  end
end
