class AnalysisJob < ActiveJob::Base
  queue_as :default

  def perform(measurable_type, measurable_id)
    Analysis.compute(measurable_type, measurable_id)
  end
end
