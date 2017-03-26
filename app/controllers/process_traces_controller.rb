class ProcessTracesController < ApplicationController
  def show
    @process_trace = ProcessTrace.find(params[:id])
    @stats = @process_trace.analysis_computed ? @process_trace.stats.includes(:stat_category) : []
  end
end
