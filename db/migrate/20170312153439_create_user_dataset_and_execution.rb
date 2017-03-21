class CreateUserDatasetAndExecution < ActiveRecord::Migration[5.0]
  def change
    create_table :users do |t|
			t.string :lastname, null: false
			t.string :firstname, null: false
			t.string :email, null: false, index: true
			t.string :institution
			t.timestamps
    end

    create_table :app_traces do |t|
    	t.string :archive, null: false
			t.string :app, index: true
			t.string :cmd
			t.integer :connectivity, index: true
			t.text :description
			t.integer :events_count
			t.boolean :imported, default: false
			t.string :kernel 
			t.text :log
			t.string :machine
			t.integer :os, index: true
			t.integer :socket_traces_count
			t.boolean :stats_computed, default: false
			t.references :user, index: true
			t.text :version
			t.text :workload, null: false
			t.timestamps
    end

		create_table :socket_traces do |t|
			t.references :app_trace, index: true	
			t.integer :events_count
			t.integer :socket_type, index: true
			t.boolean :stats_computed, default: false
			t.timestamps
		end

  end
end
