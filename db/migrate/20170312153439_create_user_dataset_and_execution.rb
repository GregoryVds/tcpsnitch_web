class CreateUserDatasetAndExecution < ActiveRecord::Migration[5.0]
  def change
    create_table :users do |t|
			t.string :lastname, null: false
			t.string :firstname, null: false
			t.string :email, null: false, index: true
			t.string :institution
			t.timestamps
    end

    create_table :traces do |t|
			t.string :app, index: true
			t.string :cmd
			t.integer :connectivity, index: true
			t.text :description
			t.string :kernel 
			t.text :log
			t.string :machine
			t.text :net
			t.string :os, index: true
    	t.string :zip_file, null: false
			t.references :user, index: true
			t.timestamps
    end
  end
end
