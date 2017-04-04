ActiveAdmin.register AppTrace do
  filter :process_trace_id
  filter :socket_trace_id
  filter :analysis_computed
  filter :app
  filter :app_version
  filter :cmd
  filter :connectivity
  filter :comments
  filter :events_imported
  filter :git_hash
  filter :kernel
  filter :log
  filter :machine
  filter :net
  filter :opt_b
  filter :opt_f
  filter :opt_u
  filter :os
  filter :version
  filter :workload
  filter :created_at
  filter :updated_at

  permit_params :app,
                :app_version,
                :cmd,
                :comments,
                :connectivity,
                :workload
end
