class Stat < ActiveRecord::Base
  include CachedCollection

  serialize :event_filters, Hash

  enum stat_type: {count_by_group: 0, cdf: 1, descriptive: 2,
                   sum_by_group: 3, pc_true_for_nodes: 4,
                   count_distinct: 5, count_distinct_by_group: 6}

  belongs_to :stat_category, inverse_of: :stats

  validates :name, :stat_category, :stat_type, presence: true
  validates :name, uniqueness: true

  scope :front, -> { where(name: ["Functions usage", "Bytes sent/received"]) }
  scope :category, -> (cat_id) { where(stat_category_id: cat_id) }

  def self.front_stats
    cached_collection(front, "front")
  end

  def self.with_category_id(id)
    cached_collection(category(id), "category#{id}")
  end

  def collection?
    !count_distinct?
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
    if count_by_group? then
      Event.count_by_group(where, group_by)
    elsif cdf? then
      count = Event.count(where)
      cdf(Event.count_by_group(where, node), count)
    elsif sum_by_group?
      Event.sum_by_group(where, group_by, node)
    elsif pc_true_for_nodes?
      node.split(',').map{|n| pc_true_for_node(where, n)}.compact
    elsif count_distinct?
      Event.count_distinct(where, node)
    elsif count_distinct_by_group?
      Event.count_distinct_by_group(where, node, group_by)
    end
  end

  def cdf(count_by_group, total_count)
    sorted_on_val= count_by_group.sort
    cdf = []
    running_count = 0
    sorted_on_val.each do |val, count|
      running_count += count
      cdf.push([val, running_count.to_f/total_count * 100.0])
    end
    return cdf
  end

  def pc_true_for_node(where, node)
    cbv = Event.count_by_group(where, node)
    return nil if cbv.empty?
    # cbv is like [[true, true_count], [false, false_count]] with order not
    # fixed, and also no guarantees to have 2 values.
    pc_true = if cbv.size == 1
      cbv[0][0] ? 1.0 : 0.0
    else
      true_count = cbv[0][0] ? cbv[0][1] : cbv[1][1]
      (true_count.to_f / (cbv[0][1] + cbv[1][1])).round(4)
    end
    [node.split('.').last, pc_true]
  end
end
