ActiveAdmin.register SocketTrace do
  filter :app_trace_id
  filter :process_trace_id
  filter :events_imported
  filter :index
  filter :socket_type
  filter :analysis_computed
  filter :created_at
  filter :updated_at

  index do
    id_column
    column :socket_type
    column :index
    column :analysis_computed
    column :events_imported
    column :created_at
    column :updated_at
    actions
  end
end
