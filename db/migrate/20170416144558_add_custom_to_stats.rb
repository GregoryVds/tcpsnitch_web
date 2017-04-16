class AddCustomToStats < ActiveRecord::Migration[5.0]
  def change
    add_column :stats, :custom, :text
  end
end
