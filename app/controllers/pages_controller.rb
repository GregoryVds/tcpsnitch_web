class PagesController < ApplicationController
  FILTERS = [:os, :connectivity]

  def home
    sanitize_filters
    @dataset_segment = DatasetSegment.new(params[:os], params[:connectivity])
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
