class ChangeDefaultApplyTo < ActiveRecord::Migration[5.0]
  def change
    change_column_default(:stats, :apply_to_app_trace, true)
    change_column_default(:stats, :apply_to_process_trace, true)
    change_column_default(:stats, :apply_to_socket_trace, true)
  end
end
