class AppTracesController < ApplicationController
  FILTERS = [:os, :app]
  IMPORTED_SHORTLY = "Trace archive will be imported shortly. Refresh this page in a few seconds..."
  COMPURTED_SHORTLY = "Trace analysis will be computed shortly. Refresh this page in a few seconds..."

  protect_from_forgery except: [:create]

  def index
    sanitize_filters
    @app_traces = AppTrace.imported.where(nil)
    FILTERS.each do |filter|
      @app_traces = @app_traces.where(filter => params[filter]) if params[filter].present?
    end
  end

  def show
    @app_trace = AppTrace.find(params[:id])
    @stats = @app_trace.analysis_computed ? @app_trace.stats.includes(:stat_category) : []
    flash[:notice] = IMPORTED_SHORTLY unless @app_trace.events_imported
    flash[:notice] = COMPURTED_SHORTLY if @app_trace.events_imported && !@app_trace.analysis_computed
  end

  def new
    @app_trace = AppTrace.new
  end

  def create
    @app_trace = AppTrace.new(trace_params)
    if @app_trace.save
      flash[:notice] = IMPORTED_SHORTLY
      redirect_to @app_trace
    else
      flash.now[:error] = @app_trace.errors.full_messages.join('<br/>').html_safe
      render :new
    end
  end
  
  def destroy
    @app_trace = AppTrace.find(params[:id])
    @app_trace.destroy
    redirect_to app_traces_path   
  end

  private

  def trace_params
    params.require(:app_trace).permit(:archive, :connectivity, :description, :workload)
  end

  def sanitize_filters
    FILTERS.each do |filter|
      params[filter].reject!(&:blank?) if params.has_key?(filter)
    end
  end
end
