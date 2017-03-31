class Stat < ActiveRecord::Base
  serialize :event_filters, Hash

  enum stat_type: {proportion: 0, cdf: 1, descriptive: 2}

  belongs_to :stat_category, inverse_of: :stats

  validates :name, :node, :stat_category, :stat_type, presence: true
  validates :name, uniqueness: true

  def event_filters=(val)
    val = eval(val) if val.is_a?(String) # Hack for ActiveAdmin... Probably a better solution exists
    write_attribute(:event_filters, val)
  end

  def compute(measurable)
    where = event_filters.merge(measurable.filter).merge(fake_call: false)
    if proportion? then
      Event.count_by_val(node, where)
    elsif cdf? then
      cdf(Event.vals(node, where))
    end
  end

  def cdf(sorted_val)
    sorted_val.map do |el|
      pc = ((sorted_val.rindex { |v| v <= el } || -1.0) + 1.0) / sorted_val.size * 100.0
      [el, pc]
    end.uniq
  end
end
