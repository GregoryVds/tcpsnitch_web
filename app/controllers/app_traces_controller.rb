class AppTracesController < ApplicationController
	FILTERS = [:os, :app]

	def index
		sanitize_filters
		@app_traces = AppTrace.where(nil)
		@app_traces = @app_traces.where(os: params[:os]) if params[:os].present? 
	 	@app_traces = @app_traces.where(app: params[:app]) if params[:app].present?
	end

	def show
		@app_trace = AppTrace.find(params[:id])
	end

	def new
		@app_trace = AppTrace.new
	end

	def create
		@app_trace = AppTrace.new(trace_params)
		if @app_trace.save
			redirect_to @app_trace
		else
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
		params.require(:app_trace).permit(:archive, :description, :workload)
	end

	def sanitize_filters
		FILTERS.each do |filter|
			params[filter].reject!(&:blank?) if params.has_key?(filter)
		end
	end
end
