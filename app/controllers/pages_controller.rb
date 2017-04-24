class PagesController < ApplicationController
  FILTERS = [:os, :connectivity]

  def home
    sanitize_filters
    @cache_val = DatasetAnalysis.cache_val(params[:os], params[:connectivity])
    @stat_categories = StatCategory.applies_to(:dataset)
  end

  def about
  end

  private

  # Replace blanks by nil
  def sanitize_filters
    FILTERS.each do |filter|
      params[filter] = nil if params[filter].blank?
    end
  end
end
