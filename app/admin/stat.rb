ActiveAdmin.register Stat do

# See permitted parameters documentation:
# https://github.com/activeadmin/activeadmin/blob/master/docs/2-resource-customization.md#setting-up-strong-parameters
#
permit_params :apply_to_app_trace,
              :apply_to_process_trace,
              :apply_to_socket_trace,
              :event_filters,
              :name,
              :node,
              :stat_category_id,
              :stat_type
#
# or
#
# permit_params do
#   permitted = [:permitted, :attributes]
#   permitted << :other if params[:action] == 'create' && current_user.admin?
#   permitted
# end


end
