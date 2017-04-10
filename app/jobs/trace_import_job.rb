class TraceImportJob < ActiveJob::Base
  queue_as :default

  def perform(app_trace_id)
    @app_trace = AppTrace.find(app_trace_id)
    # Destroy anything that is already in database. This is convenient for
    # reimporting traces and for import jobs that fail and would otherwise
    # duplicate data. This means we can import a trace as often as we like.
    @app_trace.process_traces.all.each(&:destroy)
    @app_trace.events_imported = false
    @app_trace.analysis_computed = false

    extract_archive
    update_meta_infos
    @app_trace.save! # Only proceeed if META info valid

    @app_trace.events_count = create_process_traces!
    @app_trace.events_imported = true
    @app_trace.save!
    rm_extracted_archive
    @app_trace.schedule_analysis
  end

  def extract_archive
    @extract_dir = `mktemp -d`.chomp("\n")
    extract_cmd = @app_trace.archive_is_zip ? "unzip" : "tar -xzf" 
    system("cd #{@extract_dir} && #{extract_cmd} #{@app_trace.archive.file.path}")
  end

  def read_file(path)
    str = File.read(path)
    str ? str.strip : ''
  end

  def update_meta_infos
    AppTrace::META.each do |meta|
      @app_trace.send("#{meta}=", read_file("#{@extract_dir}/meta/#{meta}").downcase)
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
      p.logs = read_file("#{dir}/logs.txt")
      p.events_count = create_socket_traces!(p.id, dir)
      p.events_imported = true
      p.save!
      p.schedule_analysis
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
        s.events_imported = true
        s.save!
        s.schedule_analysis
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
