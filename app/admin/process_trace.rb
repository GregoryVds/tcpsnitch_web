ActiveAdmin.register ProcessTrace do
  filter :app_trace_id
  filter :socket_trace_id
  filter :analysis_computed
  filter :events_imported
  filter :name
  filter :logs
  filter :created_at
  filter :updated_at

  index do
    selectable_column
    id_column
    column :name
    column :analysis_computed
    column :events_imported
    column :created_at
    column :updated_at
    actions
  end
end
