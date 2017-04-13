class StatCategory < ActiveRecord::Base
  include CachedCollection

  has_many :subcategories, class_name: :StatCategory, foreign_key: :parent_category_id, dependent: :destroy
  belongs_to :parent_category, class_name: :StatCategory, optional: true, touch: true
  has_many :stats, inverse_of: :stat_category, dependent: :destroy

  validates :name, presence: true, uniqueness: true

  scope :root, -> { where(parent_category_id: nil).order(:id) }
  scope :leaf, -> { where.not(parent_category: nil).order(:id) }
  scope :children, -> (parent_id) { where(parent_category_id: parent_id).order(:id) }

  def self.root_categories
    cached_collection(root, "leaf")
  end

  def self.leaf_categories
    cached_collection(leaf, "root")
  end

  def self.children_of(parent_id)
    cached_collection(children(parent_id), "children#{parent_id}")
  end

  def pretty_name
    name.sub(/^./, &:upcase)
  end

  def applies_to?(trace)
    if trace.class == AppTrace then applies_to_app_trace
    elsif trace.class == ProcessTrace then applies_to_process_trace
    else applies_to_socket_trace
    end
  end
end
