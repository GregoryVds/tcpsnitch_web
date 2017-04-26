class StatDecorator < Draper::Decorator
  delegate_all

  # Charts

  def chart?
    !number?
  end

  def pie_chart?
    count_by_group?
  end

  def bar_chart?
    count_distinct_node_val_by_group?
  end

  def line_chart?
    node_val_cdf? or node_val_cdf_for_filters?
  end

  def column_chart?
    sum_node_val_by_group? or sum_node_val_for_filters?
  end

  def column_chart_pc?
    pc_true_for_nodes?
  end

  # Data

  def show_data?
    !number? and !line_chart?
  end

  def data_decimal?
    node_val_cdf? or
    node_val_cdf_for_filters?
  end

  def data_point(val)
    if data_decimal?
      h.number_with_precision(val)
    else
      h.number_with_delimiter(val)
    end
  end

  def pc(val, total)
    "#{h.number_with_precision(val.to_f/total*100)}%"
  end

  def data_summable?
    count_by_group? or
    sum_node_val_by_group? or
    sum_node_val_for_filters?
  end

  def pretty_name
    name.sub(/^./, &:upcase)
  end
end
