module Analysable
  extend ActiveSupport::Concern

  def filter
    raise NotImplementedError
  end

  def analysable_type
    raise NotImplementedError
  end
end
