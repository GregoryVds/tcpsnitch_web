class RemoveApplyToOnStats < ActiveRecord::Migration[5.0]
  def change
    remove_column :stats, :apply_to_app_trace
    remove_column :stats, :apply_to_process_trace
    remove_column :stats, :apply_to_socket_trace
  end
end
