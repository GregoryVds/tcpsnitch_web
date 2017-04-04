ActiveAdmin.register ProcessTrace do
  filter :app_trace_id
  filter :socket_trace_id
  filter :analysis_computed
  filter :events_imported
  filter :name
  filter :created_at
  filter :updated_at
end
