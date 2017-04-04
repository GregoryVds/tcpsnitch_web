ActiveAdmin.register AppTrace do
  permit_params :app,
                :app_version,
                :cmd,
                :comments,
                :connectivity,
                :workload
end
