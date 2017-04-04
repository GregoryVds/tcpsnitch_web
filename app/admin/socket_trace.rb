ActiveAdmin.register SocketTrace do
  filter :app_trace_id
  filter :process_trace_id
  filter :events_imported
  filter :index
  filter :socket_type
  filter :analysis_computed
  filter :created_at
  filter :updated_at
end
