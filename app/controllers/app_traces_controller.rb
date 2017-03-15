class AppTracesController < ApplicationController
	def index
		@app_traces = AppTrace.all
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

end
