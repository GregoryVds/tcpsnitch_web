class MoveLogsToProcessTrace < ActiveRecord::Migration[5.0]
  def change
    add_column :process_traces, :logs, :text
    remove_column :app_traces, :log, :text
  end
end
