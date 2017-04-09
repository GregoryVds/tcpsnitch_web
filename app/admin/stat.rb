ActiveAdmin.register Stat do

  permit_params :event_filters,
                :name,
                :node,
                :stat_category_id,
                :stat_type

  index do
    id_column
    column :name
    column :stat_type
    column :node
    column :event_filters
    column :description
    column :created_at
    column :updated_at
    actions
  end
end
