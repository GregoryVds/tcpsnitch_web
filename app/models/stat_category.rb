class StatCategory < ActiveRecord::Base
  include CachedCollection
  has_many :stats, inverse_of: :stat_category, dependent: :destroy

  validates :name, presence: true, uniqueness: true

  scope :applies_to_scope, -> (analysable_type) { where("applies_to_#{analysable_type}": true) }
  scope :left_menu_scope, -> (analysable_type) { applies_to_scope(analysable_type).where.not(name: 'Overview').order(id: :asc) }

  def self.applies_to(analysable_type)
    cached_collection(applies_to_scope(analysable_type), "applies_to_#{analysable_type}")
  end

  def self.left_menu(analysable_type)
    cached_collection(left_menu_scope(analysable_type), "left_menu_#{analysable_type}")
  end

  def pretty_name
    name.sub(/^./, &:upcase)
  end
end
