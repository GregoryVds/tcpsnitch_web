class DatasetAnalysisJob < ActiveJob::Base
  queue_as :low

  def perform(segment_type)
    analysable = DatasetSegment.new(segment_type)
    analysable.analysis.update(analysable)
  end
end
