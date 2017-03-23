class StatCategory < ActiveRecord::Base
  has_many :subcategories, class_name: :StatCategory, foreign_key: :parent_category_id, dependent: :destroy
  belongs_to :parent_category, class_name: :StatCategory, optional: true
  has_many :stats, inverse_of: :stat_category, dependent: :destroy

  validates :name, presence: true

  scope :top_level, -> { where(parent_category_id: nil) }
end
