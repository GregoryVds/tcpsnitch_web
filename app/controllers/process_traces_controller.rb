class ProcessTracesController < ApplicationController
  def show
    @process_trace = ProcessTrace.find(params[:id])
    @front_stats = Stat.front_stats
    @stats = @process_trace.analysis_computed ? @process_trace.stats.includes(:stat_category) : []
  end
end
