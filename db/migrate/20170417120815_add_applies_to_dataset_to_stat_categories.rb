class AddAppliesToDatasetToStatCategories < ActiveRecord::Migration[5.0]
  def change
    add_column :stat_categories, :applies_to_dataset, :boolean, default: true
  end
end
