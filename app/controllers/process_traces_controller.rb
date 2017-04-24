class ProcessTracesController < ApplicationController
  def show
    @process_trace = ProcessTrace.includes(:socket_traces).find(params[:id])
    @stat_categories = StatCategory.left_menu(@process_trace.analysable_type)
    @analysis = @process_trace.analysis
  end
end
