class TracesController < ApplicationController
	def index
		@traces = Trace.all
	end

	def show
		@trace = Trace.find(params[:id])
	end

	def new
		@trace = Trace.new
	end

	def create
		@trace = Trace.new(trace_params)
		if @trace.save
			redirect_to @trace
		else
			render :new
		end
	end
	
	def destroy
		@trace = Trace.find(params[:id])
		@trace.destroy
		redirect_to traces_path		
	end

	private

	def trace_params
		params.require(:trace).permit(:description, :zip_file)
	end

end
