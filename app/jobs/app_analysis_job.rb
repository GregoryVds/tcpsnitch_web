class AppAnalysisJob < ActiveJob::Base
  queue_as :low

  def perform(id)
    AppTrace.find(id).update_analysis
  end
end
