class RemoveParentCategoryIdOnStatCategories < ActiveRecord::Migration[5.0]
  def change
    remove_column :stat_categories, :parent_category_id
  end
end
