class SocketTraceImportJob < ActiveJob::Base
  BATCH_SIZE=50000
  queue_as :default

  def perform(app_trace_id, process_trace_id, socket_trace_id, file)
    @app_trace = AppTrace.find(app_trace_id)
    @process_trace = ProcessTrace.find(process_trace_id)
    @socket_trace = SocketTrace.find(socket_trace_id)
    @events_count = 0
    @batch = []

    import_events(file)

    @socket_trace.events_count = @events_count
    @socket_trace.socket_type = @socket_type
    @socket_trace.events_imported = true
    @socket_trace.save!
    @socket_trace.schedule_analysis

    @process_trace.increment!(:events_count, @events_count)
    @app_trace.increment!(:events_count, @events_count)

    if SocketTrace.where(process_trace_id: @process_trace.id, events_imported: false).empty?
      @process_trace.events_imported = true
      @process_trace.save!
      @process_trace.schedule_analysis unless @process_trace.analysis_computed
    end

    if ProcessTrace.where(app_trace_id: @app_trace.id, events_imported: false).empty?
      @app_trace.events_imported = true
      @app_trace.save!
      @app_trace.schedule_analysis unless @app_trace.analysis_computed
    end
  end

  def parse_json_event(line)
    Oj.load(line.chomp("\n"))
  end

  def import_events(file)
    File.open(file).lazy.map do |line|
      parse_json_event(line)
    end.map do |hash|
      enrich(hash)
    end.each do |event|
      @socket_type = socket_type(event) if @events_count==0
      new_event(event)
    end
    dump_to_mongo
  end

  def new_event(event)
    @batch.push(event)
    @events_count += 1
    dump_to_mongo if @batch.size == BATCH_SIZE
  end

  def dump_to_mongo
    Event.collection.insert_many(@batch)
    @batch = []
  end

  def socket_type(event)
    event['details']['sock_info']['type']
  end

  def enrich(event_hash)
    event_hash['app'] = @app_trace.app
    event_hash['app_trace_id'] = @app_trace.id
    event_hash['connectivity'] = @app_trace.connectivity_int
    event_hash['index'] = @events_count
    event_hash['os'] = @app_trace.os_int
    event_hash['process_trace_id'] = @process_trace.id
    event_hash['socket_trace_id'] = @socket_trace.id
    # TODO: Time since
    event_hash
  end
end
