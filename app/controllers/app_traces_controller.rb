class AppTracesController < ApplicationController
  FILTERS = [:os, :app]
  UPLOADED="Trace successfully uploaded"
  UPLOAD_FAIL="Failed to upload trace"
  IMPORTED_SHORTLY = "Trace archive will be imported shortly. Refresh this page in a few minutes..."
  COMPURTED_SHORTLY = "Trace analysis will be computed shortly. Refresh this page in a few minutes..."

  protect_from_forgery except: [:create]

  def index
    sanitize_filters
    @app_traces = AppTrace.order(created_at: :desc).imported.where(nil).page(params[:page])
    FILTERS.each do |filter|
      @app_traces = @app_traces.where(filter => params[filter]) if params[filter].present?
    end
  end

  def show
    @app_trace = AppTrace.includes(:process_traces).find(params[:id])
    @front_stats = Stat.front_stats
    @stats = @app_trace.analysis_computed ? @app_trace.stats.includes(:stat_category) : []
    flash[:notice] = IMPORTED_SHORTLY unless @app_trace.events_imported
    flash[:notice] = COMPURTED_SHORTLY if @app_trace.events_imported && !@app_trace.analysis_computed
  end

  def new
    @app_trace = AppTrace.new
  end

  def create
    @app_trace = AppTrace.new(trace_params)
    if params[:authenticity_token]
      if @app_trace.save
        flash[:notice] = IMPORTED_SHORTLY
        redirect_to @app_trace
      else
        flash.now[:error] = @app_trace.errors.full_messages.join('<br/>').html_safe
        render :new
      end
    else
      if @app_trace.save
        render plain: "#{UPLOADED} at #{app_trace_url(@app_trace)}.\n#{IMPORTED_SHORTLY}\n"
      else
        render plain: "#{UPLOAD_FAIL}: #{@app_trace.errors.full_messages.join(', ')}.\n"
      end
    end
  end

  private

  def trace_params
    params.require(:app_trace).permit(:archive, :connectivity, :comments, :workload)
  end

  def sanitize_filters
    FILTERS.each do |filter|
      params[filter].reject!(&:blank?) if params.has_key?(filter)
    end
  end
end
