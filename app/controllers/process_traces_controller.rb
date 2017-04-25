class ProcessTracesController < ApplicationController
  def show
    @process_trace = ProcessTrace.includes(:socket_traces).find(params[:id])
    @analysis = @process_trace.analysis
  end
end
