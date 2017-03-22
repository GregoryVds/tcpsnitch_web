class ProcessTracesController < ApplicationController
  def show
    @process_trace = ProcessTrace.find(params[:id])
  end
end
