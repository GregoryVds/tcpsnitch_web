class Stat
  attr_reader :type, :node, :event_filters
  def initialize(type, node, **event_filters)
    @type, @node, @event_filters = type, node, event_filters
  end
end
