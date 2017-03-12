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
			t.text :description, null: false
			t.integer :os, default: 0, null: false, index: true
			t.string :kernel, null: false, index: true
			t.date :upload_date, null: false
			t.references :user, index: true
			t.timestamps
    end
		add_foreign_key :datasets, :users

    create_table :executions do |t|
			t.string :application, null: false, index: true
			t.integer :connectivity, default: 0, null: false, index: true
			t.references :dataset, index: true
			t.timestamps
    end
		add_foreign_key :executions, :datasets

  end
end
