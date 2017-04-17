class ProcessTracesController < ApplicationController
  def show
    @process_trace = ProcessTrace.find(params[:id])
    @stat_categories = StatCategory.left_menu(@process_trace)
    @analysis = @process_trace.analysis
  end
end
