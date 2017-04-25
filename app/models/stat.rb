class Stat < ActiveRecord::Base
  include CachedCollection

  serialize :event_filters, Hash
  serialize :custom, Hash

  enum stat_type: [
    :simple_count,
    :count_by_group,
    :count_distinct_node_val,
    :count_distinct_node_val_by_group,
    :node_val_cdf,
    :sum_node_val_by_group,
    :sum_node_val_for_filters,
    :pc_true_for_nodes
  ]

  belongs_to :stat_category, inverse_of: :stats

  validates :name, :stat_category, :stat_type, presence: true
  validates :name, uniqueness: true

  scope :category_scope, -> (cat_id, analysable_type) { where(stat_category_id: cat_id, "applies_to_#{analysable_type}": true).order(id: :asc) }

  def self.category(id, analysable_type)
    cached_collection(category_scope(id, analysable_type), "category_#{id}_#{analysable_type}")
  end

  def collection?
    !number?
  end

  def number?
    count_distinct_node_val? or simple_count?
  end

  def data_summable?
    count_by_group? or
    sum_node_val_by_group? or
    sum_node_val_for_filters?
  end

  def data_decimal?
    node_val_cdf?
  end

  def pretty_name
    name.sub(/^./, &:upcase)
  end

  def custom=(val)
    val = eval(val) if val.is_a?(String) # Hack for ActiveAdmin
    write_attribute(:custom, val)
  end

  def event_filters=(val)
    val = eval(val) if val.is_a?(String) # Hack for ActiveAdmin
    write_attribute(:event_filters, val)
  end

  def simple_count(filter)
    Event.simple_count(filter)
  end

  def count_by_group(filter)
    Event.count_by_group(filter, group_by)
  end

  def count_distinct_node_val(filter)
    Event.count_distinct_node_val(filter, node)
  end

  def count_distinct_node_val_by_group(filter)
    Event.count_distinct_node_val_by_group(filter, node, group_by)
  end

  def node_val_cdf(filter)
    total_count = Event.simple_count(filter)
    cdf(Event.count_by_group(filter, node), total_count)
  end

  def sum_node_val_by_group(filter)
    Event.sum_node_val_by_group(filter, group_by, node)
  end

  def sum_node_val_for_filters(filter)
    Event.sum_node_val_for_filters(filter, node, custom)
  end

  def pc_true_for_nodes(filter)
    node.split(',').map{|n| pc_true_for_node(filter, n)}.compact
  end

  def compute(filter)
    where = event_filters.merge(filter).merge(fake_call: false)
    send(stat_type, where)
  end

  def cdf(count_by_group, total_count)
    running_count = 0
    last_pc_selected = nil
    count_by_group.sort.map do |val, count|
      running_count += count
      [val, running_count.to_f/total_count * 100.0]
    end.select do |val, pc|
      if last_pc_selected.nil? or (pc - last_pc_selected) >= 0.2
        last_pc_selected = pc
        true
      else
        false
      end
    end
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

  def data(analysis)
    return nil if (analysis.nil? or analysis.measures.nil?)
    data = analysis[:measures][name]
    if collection?
      (data.nil? or data.empty?) ? nil : data # We don't want an empty array, but nil.
    else
      data
    end
  end
end
