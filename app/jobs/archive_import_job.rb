class ArchiveImportJob < ActiveJob::Base
  queue_as :default

  def perform(app_trace_id)
    @app_trace = AppTrace.find(app_trace_id)
    # Destroy anything that is already in database. This is convenient for
    # reimporting traces and for import jobs that fail and would otherwise
    # duplicate data. This task is thus indempotent.
    @app_trace.process_traces.all.each(&:destroy)
    @app_trace.events_imported = false
    @app_trace.analysis_computed = false
    @app_trace.save! # Need a save to expire cache quickly.

    extract_archive
    update_meta_infos
    @app_trace.save! # Only proceeed if meta info valid.

    # Now create all Postgresql object (process traces & socket traces).
    # We however do not imported the events yet.
    @jobs = []
    create_process_traces!
    @app_trace.touch

    @jobs.each do |process_id, socket_id, trace|
      SocketTraceImportJob.perform_later(@app_trace.id, process_id, socket_id, trace)
    end
  end

  def extract_archive
    @extract_dir = `mktemp -p ./tmp -d`.chomp("\n")
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

  def process_traces
    Dir.glob("#{@extract_dir}/*").sort.select{|f| File.directory?(f) }.select{ |f| f !~ /meta$/ }
  end

  def create_process_traces!
    process_traces.each do |dir|
      next if Dir["#{dir}/*.json"].empty? # Sockets with no calls. Does it still happen with tcpsnitch?
      p = ProcessTrace.create!({
        app_trace_id: @app_trace.id,
        name: dir.split('/').last,
        logs: read_file("#{dir}/logs.txt")
      })
      create_socket_traces!(p.id, dir)
    end
  end

  def create_socket_traces!(process_trace_id, dir)
    Dir.glob("#{dir}/*.json").sort_by { |f| File.mtime(f) }.each do |socket_trace|
      s = SocketTrace.create!({
        app_trace_id: @app_trace.id,
        process_trace_id: process_trace_id,
        index: socket_trace.split('/').last.to_i
      })
      @jobs.push([process_trace_id, s.id, socket_trace])
    end
  end

  def rm_extracted_archive
    system("rm -rf #{@extract_dir}")
  end
end
