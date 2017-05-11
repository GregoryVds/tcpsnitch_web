module Analysable
  extend ActiveSupport::Concern

  # Interface to implement
  # - events_filter
  # - analysable_type
  # - analysable_id
  # - os
  # - connectivity

  def analysis_filter
    {analysable_type: analysable_type, analysable_id: analysable_id}
  end

  def analysis_attr
    base_attr = {measures: {}, os: AppTrace.os[os]}
    base_attr.merge!({remote_con: remote_con, socket_type: socket_type}) if analysable_type == :socket_trace
    base_attr
  end

  def analysis
    a = Analysis.where(analysis_filter).first
    a ? a : Analysis.create!(analysis_filter.merge(analysis_attr))
  end

  def destroy_analysis
    analysis.destroy! if analysis
  end

  def analysis_cache_key
    Analysis.where(analysis_filter).pluck(:id, :updated_at)
  end

  def socket_ids
    id_column = (analysable_type == :socket_trace ? :id : "#{analysable_type}_id")
    SocketTrace.where(id_column => analysable_id).pluck(:id)
  end
end
