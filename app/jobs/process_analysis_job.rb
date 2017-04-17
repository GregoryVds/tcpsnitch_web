class ProcessAnalysisJob < ActiveJob::Base
  queue_as :xlow

  def perform(id)
    ProcessTrace.find(id).update_analysis
  end
end
