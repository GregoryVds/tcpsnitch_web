class AnalysisController < ApplicationController
  FILTERS = [:os, :connectivity]

  def show
    @dataset = Dataset.get
    @analysis_updated_at = @dataset.analysis_updated_at
    @stat_categories = StatCategory.applies_to(@dataset)
  end
end
