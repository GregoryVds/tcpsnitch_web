class AddDescriptionToStats < ActiveRecord::Migration[5.0]
  def change
    add_column :stats, :description, :string
  end
end
