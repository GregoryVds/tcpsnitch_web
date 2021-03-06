class CreateInitialSchema < ActiveRecord::Migration[5.0]
  def change
    create_table :app_traces do |t|
      t.boolean :analysis_computed, default: false
      t.string :archive, null: false
      t.string :app, index: true
      t.string :app_version
      t.string :cmd
      t.integer :connectivity, index: true
      t.text :comments
      t.integer :events_count
      t.boolean :events_imported, default: false
      t.string :git_hash
      t.string :host_id
      t.string :kernel
      t.text :log
      t.string :machine
      t.text :net
      t.text :opt_b
      t.text :opt_f
      t.text :opt_u
      t.integer :os, index: true
      t.integer :process_traces_count
      t.integer :socket_traces_count
      t.references :user, index: true
      t.text :version
      t.text :workload
      t.timestamps
    end

    create_table :process_traces do |t|
      t.references :app_trace, index: true
      t.boolean :events_imported, default: false
      t.string :name
      t.integer :events_count
      t.integer :socket_traces_count
      t.boolean :analysis_computed, default: false
      t.timestamps
    end

    create_table :socket_traces do |t|
      t.references :app_trace, index: true
      t.integer :events_count
      t.boolean :events_imported, default: false
      t.references :process_trace, index: true
      t.integer :index
      t.integer :socket_type, index: true
      t.boolean :analysis_computed, default: false
      t.timestamps
    end

    create_table :stat_categories do |t|
      t.string :name
      t.string :info
      t.references :parent_category
      t.timestamps
    end

    create_table :stats do |t|
      t.boolean :apply_to_app_trace, default: false
      t.boolean :apply_to_process_trace, default: false
      t.boolean :apply_to_socket_trace, default: false
      t.text :event_filters
      t.string :name
      t.string :node
      t.references :stat_category
      t.integer :stat_type
      t.timestamps
    end
  end
end
