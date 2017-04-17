class DatasetAnalysisJob < ActiveJob::Base
  queue_as :low

  def perform
    Dataset.get.analysis.update(Dataset.get)
  end
end
