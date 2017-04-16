class StatCategory < ActiveRecord::Base
  include CachedCollection
  has_many :stats, inverse_of: :stat_category, dependent: :destroy

  validates :name, presence: true, uniqueness: true

  def self.left_menu
    cached_collection(where.not(name: 'about').order(id: :asc), 'left_menu')
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
