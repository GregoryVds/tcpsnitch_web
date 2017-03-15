class TraceImportJob < ActiveJob::Base
	queue_as :default

	def perform(trace_id)
		@trace = Trace.find(trace_id)
		return if @trace.processed

		extract_archive
		update_meta_infos
		create_events if @trace.valid?
		rm_extracted_archive

		@trace.processed = true
		@trace.save!
	end

	def extract_archive
		@extract_dir = `mktemp -d`.chomp("\n")
		extract_cmd = @trace.archive_is_zip ? "unzip" : "tar -xzf" 
		system("cd #{@extract_dir} && #{extract_cmd} #{@trace.archive.file.path}")
	end

	def first_line(path)
		File.open(path, &:readline).strip
	end

	def update_meta_infos
		Trace::META.each do |meta|
			@trace.send("#{meta}=", first_line("#{@extract_dir}/meta/#{meta}")) 
		end
	end

	def parse_json_event(line)
		Oj.load(line.chomp("\n")) # TODO: error handling
	end

	def create_events
		Dir.glob("#{@extract_dir}/*.json").each_with_index do |file, index|
			File.open(file).lazy.map do |line|
				parse_json_event(line)
			end.map do |hash|
				add_trace_info(hash, index)	
			end.each do |event|
				Event.create(event)
			end
		end
	end

	def add_trace_info(event_hash, socket_num)
		event_hash['app'] = @trace.app
		event_hash['connectivity'] = @trace.connectivity_int
		event_hash['os'] = @trace.os_int
		event_hash['socket_num'] = socket_num
		event_hash['trace_id'] = @trace.id
		# TODO: time_since
		event_hash
	end
	
	def rm_extracted_archive
		system("rm -rf #{@extract_dir}")
	end
end
