class Dataset
  extend Analysable
  @@singleton = Dataset.new

  def self.get
    @@singleton
  end

  def analysis
    a = Analysis.where(analysable_type: :dataset).first
    a ? a : Analysis.create!(analysable_type: :dataset, measures: {})
  end

  def analysis_updated_at
    analysis.updated_at
  end

  def schedule_analysis
    DatasetAnalysisJob.perform_later
  end

  # Analysable

  def filter
    {}
  end

  def analysable_type
    :dataset
  end
end
