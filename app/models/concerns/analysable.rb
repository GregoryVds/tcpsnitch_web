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

  def analysis
    a = Analysis.where(analysis_filter).first
    a ? a : Analysis.create!(analysis_filter.merge({
      measures: {},
      os: AppTrace.os[os]
    }))
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
