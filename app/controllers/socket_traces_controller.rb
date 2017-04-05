class SocketTracesController < ApplicationController
  def show
    @socket_trace = SocketTrace.find(params[:id])
    @front_stats = Stat.front_stats
    @stats = @socket_trace.analysis_computed ? @socket_trace.stats.includes(:stat_category) : []
  end
end
