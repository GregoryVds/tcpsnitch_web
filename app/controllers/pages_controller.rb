class PagesController < ApplicationController
  def home
    @dataset_segment = DatasetSegment.new(params[:segment] ? params[:segment] : :global)
  end

  def about
  end
end
