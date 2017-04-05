class RenameInfoToDescriptionOnStatCategories < ActiveRecord::Migration[5.0]
  def change
    rename_column :stat_categories, :info, :description
  end
end
