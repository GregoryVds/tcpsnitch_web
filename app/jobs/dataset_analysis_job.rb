class DatasetAnalysisJob < ActiveJob::Base
  queue_as :low

  def perform(os, con)
    DatasetAnalysis.get(os, con).update
  end
end
