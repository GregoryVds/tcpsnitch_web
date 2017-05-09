class PagesController < ApplicationController
  def home
    @dataset_segment = DatasetSegment.new(params[:segment])
  end

  def about
  end
end
