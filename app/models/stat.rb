class Stat < ActiveRecord::Base
  include CachedCollection

  serialize :event_filters, Hash

  enum stat_type: {proportion: 0, cdf: 1, descriptive: 2, sum_by_group: 3}

  belongs_to :stat_category, inverse_of: :stats

  validates :name, :node, :stat_category, :stat_type, presence: true
  validates :name, uniqueness: true

  scope :front, -> { where(name: ["Functions usage", "Bytes sent/received"]) }
  scope :category, -> (cat_id) { where(stat_category_id: cat_id) }

  def self.front_stats
    cached_collection(front, "front")
  end

  def self.with_category_id(id)
    cached_collection(category(id), "category#{id}")
  end

  def pretty_name
    name.sub(/^./, &:upcase)
  end

  def event_filters=(val)
    val = eval(val) if val.is_a?(String) # Hack for ActiveAdmin... Probably a better solution exists
    write_attribute(:event_filters, val)
  end

  def compute(trace)
    where = event_filters.merge(trace.filter).merge(fake_call: false)
    if proportion? then
      Event.count_by_val(node, where)
    elsif cdf? then
      count = Event.count(where)
      cdf(Event.count_by_val(node, where), count)
    elsif sum_by_group?
      Event.sum_by_group(group_by, node, where)
    end
  end

  def cdf(count_by_val, total_count)
    sorted_on_val= count_by_val.sort
    cdf = []
    running_count = 0
    sorted_on_val.each do |val, count|
      running_count += count
      cdf.push([val, running_count.to_f/total_count * 100.0])
    end
    return cdf
  end
end
