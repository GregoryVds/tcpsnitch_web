class PagesController < ApplicationController
  def home
    @dataset = Dataset.get
    @analysis = @dataset.analysis
    @stat_categories = StatCategory.applies_to(@dataset)
  end

  def about
  end
end
