class AppTraceImportJob < ActiveJob::Base
	queue_as :default

	def perform(app_trace_id)
		@app_trace = AppTrace.find(app_trace_id)
		return if @app_trace.imported

		extract_archive
		update_meta_infos
		return unless @app_trace.valid?
		create_socket_traces
		@app_trace.schedule_stats_computation
		rm_extracted_archive

		@app_trace.events_count = @app_trace.socket_traces.sum(:events_count)
		@app_trace.imported = true
		@app_trace.save!
	end

	def extract_archive
		@extract_dir = `mktemp -d`.chomp("\n")
		extract_cmd = @app_trace.archive_is_zip ? "unzip" : "tar -xzf" 
		system("cd #{@extract_dir} && #{extract_cmd} #{@app_trace.archive.file.path}")
	end

	def first_line(path)
		File.open(path, &:readline).strip
	end

	def update_meta_infos
		AppTrace::META.each do |meta|
			@app_trace.send("#{meta}=", first_line("#{@extract_dir}/meta/#{meta}")) 
		end
	end

	def parse_json_event(line)
		Oj.load(line.chomp("\n")) # TODO: error handling
	end

	def create_socket_traces
		Dir.glob("#{@extract_dir}/*.json").each do |file|
			s = SocketTrace.create!(app_trace_id: @app_trace.id)
			s.events_count, s.socket_type = create_socket_trace_events(file, s.id)
			s.save!
		end
	end

	def create_socket_trace_events(file, socket_trace_id)
			events_count = 0
			socket_type = nil

			File.open(file).lazy.map do |line|
				parse_json_event(line)
			end.map do |hash|
				add_app_trace_info(hash)
			end.each do |event|
				event['socket_trace_id'] = socket_trace_id
				ev = Event.create(event)
				socket_type = ev.details['type'] if ev.type.eql? 'socket'
				events_count += 1
			end

			return events_count, socket_type
	end

	def add_app_trace_info(event_hash)
		event_hash['app'] = @app_trace.app
		event_hash['connectivity'] = @app_trace.connectivity_int
		event_hash['os'] = @app_trace.os_int
		event_hash['app_trace_id'] = @app_trace.id
		# TODO: time_since
		event_hash
	end
	
	def rm_extracted_archive
		system("rm -rf #{@extract_dir}")
	end
end
