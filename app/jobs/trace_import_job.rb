class TraceImportJob < ActiveJob::Base
  queue_as :default

  def perform(app_trace_id)
    @app_trace = AppTrace.find(app_trace_id)

    extract_archive
    update_meta_infos
    @app_trace.save! # Only proceeed if META info valid

    @app_trace.events_count = create_process_traces!
    @app_trace.events_imported!
    @app_trace.save!

    rm_extracted_archive
  end

  def extract_archive
    @extract_dir = `mktemp -d`.chomp("\n")
    extract_cmd = @app_trace.archive_is_zip ? "unzip" : "tar -xzf" 
    system("cd #{@extract_dir} && #{extract_cmd} #{@app_trace.archive.file.path}")
  end

  def first_line(path)
    first = File.open(path).readlines.first
    first ? first.strip : ''
  end

  def update_meta_infos
    AppTrace::META.each do |meta|
      @app_trace.send("#{meta}=", first_line("#{@extract_dir}/meta/#{meta}").downcase) 
    end
  end

  def parse_json_event(line)
    Oj.load(line.chomp("\n"))
  end

  def process_traces
    Dir.glob("#{@extract_dir}/*").sort.select{|f| File.directory?(f) }.select{ |f| f !~ /meta$/ }
  end

  def create_process_traces!
    events_count = 0
    process_traces.each do |dir|
      next if Dir["#{dir}/*.json"].empty? # Sockets with no calls (TODO: Handle this in tcpsnitch?)
      p = ProcessTrace.create!({
        app_trace_id: @app_trace.id, 
        name: dir.split('/').last
      })
      p.logs = File.read("#{dir}/logs.txt")
      p.events_count = create_socket_traces!(p.id, dir)
      p.events_imported!
      p.save!
      events_count += p.events_count
    end
    events_count
  end

  def create_socket_traces!(process_trace_id, process_trace_dir)
      events_count = 0
      Dir.glob("#{process_trace_dir}/*.json").sort_by { |f| File.mtime(f) }.each do |socket_trace|
        s = SocketTrace.create!({
          app_trace_id: @app_trace.id,
          process_trace_id: process_trace_id,
          index: socket_trace.split('/').last.to_i
        })
        s.events_count, s.socket_type = create_socket_trace_events(socket_trace, process_trace_id, s.id)
        s.events_imported!
        s.save!
        events_count += s.events_count
      end
      events_count
  end

  def create_socket_trace_events(file, process_trace_id, socket_trace_id)
      events_count = 0
      socket_type = nil

      File.open(file).lazy.map do |line|
        parse_json_event(line)
      end.map do |hash|
        add_app_trace_info(hash)
      end.each_with_index do |event, index|
        event['index'] = index
        event['process_trace_id'] = process_trace_id
        event['socket_trace_id'] = socket_trace_id
        ev = Event.create(event)
        socket_type = ev.details['sock_info']['type'] if index==0
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
