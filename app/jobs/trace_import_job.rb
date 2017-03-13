class TraceImportJob < ActiveJob::Base
	queue_as :default

	def perform(trace_path)
		# Read meta & create Execution
		meta_dir = trace_path + '/meta'
		e = Execution.new
		e.app = first_line(meta_dir + 'app')
		e.connectivity = 

		Dir.glob(trace_path + '*.json') do |json_trace|
			# Create 
			# Read all lines & insert events
		end

		puts "Hello" + trace_path	
	end
end
