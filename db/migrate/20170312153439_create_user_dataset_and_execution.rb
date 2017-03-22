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
			t.boolean :events_imported, default: false
			t.string :kernel 
			t.text :log
			t.string :machine
			t.text :net
			t.integer :os, index: true
			t.integer :process_traces_count
			t.boolean :quantitative_analysis_computed, default: false
			t.references :user, index: true
			t.text :version
			t.text :workload, null: false
			t.timestamps
    end

		create_table :process_traces do |t|
			t.references :app_trace, index: true	
			t.boolean :events_imported, default: false
			t.string :process_name
			t.integer :events_count
			t.integer :socket_traces_count
			t.boolean :quantitative_analysis_computed, default: false
			t.timestamps
		end

		create_table :socket_traces do |t|
			t.integer :events_count
			t.boolean :events_imported, default: false
			t.references :process_trace, index: true	
			t.integer :socket_type, index: true
			t.boolean :quantitative_analysis_computed, default: false
			t.timestamps
		end

  end
end
