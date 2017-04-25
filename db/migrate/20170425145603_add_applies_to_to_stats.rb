class AddAppliesToToStats < ActiveRecord::Migration[5.0]
  def change
    add_column :stats, :applies_to_socket_trace, :boolean, default: true
    add_column :stats, :applies_to_process_trace, :boolean, default: true
    add_column :stats, :applies_to_app_trace, :boolean, default: true
    add_column :stats, :applies_to_dataset, :boolean, default: true
  end
end
