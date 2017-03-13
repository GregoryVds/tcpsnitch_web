class CreateUserDatasetAndExecution < ActiveRecord::Migration[5.0]
  def change
    create_table :users do |t|
			t.string :lastname, null: false
			t.string :firstname, null: false
			t.string :email, null: false, index: true
			t.string :institution
			t.timestamps
    end

    create_table :datasets do |t|
			t.string :name, null: false
			t.text :description
			t.references :user, index: true
			t.timestamps
    end
		add_foreign_key :datasets, :users

    create_table :executions do |t|
			t.string :app, null: false, index: true
			t.string :cmd
			t.integer :connectivity, default: 0, null: false, index: true
			t.string :kernel 
			t.text :log
			t.string :machine
			t.text :net
			t.string :os, default: 0, null: false, index: true
			t.references :dataset, index: true
			t.timestamps
    end
		add_foreign_key :executions, :datasets

  end
end
