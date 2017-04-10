module Trace
  extend ActiveSupport::Concern

  included do
    include Analysable
    before_destroy :destroy_events
  end

  def events
    @events ||= Event.where(filter)
  end

  def trace_type
    self.class.table_name.singularize
  end

  def filter
    {"#{trace_type}_id": id}
  end

  def destroy_events
    events.delete_all if events
  end
end
