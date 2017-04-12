class AddGroupByToStats < ActiveRecord::Migration[5.0]
  def change
    add_column :stats, :group_by, :string
  end
end
