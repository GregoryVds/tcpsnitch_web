class DatasetAnalysisJob < ActiveJob::Base
  queue_as :low

  def perform(os, con)
    analysable = DatasetSegment.new(os, con)
    analysable.analysis.update(analysable)
  end
end
