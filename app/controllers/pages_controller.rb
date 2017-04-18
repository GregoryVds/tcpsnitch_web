class PagesController < ApplicationController
  def home
    @dataset = Dataset.get
    @analysis_updated_at = @dataset.analysis_updated_at
    @stat_categories = StatCategory.applies_to(@dataset)
  end

  def about
  end
end
