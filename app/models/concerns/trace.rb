module Trace
  extend ActiveSupport::Concern

  included do
    extend Analysable
    after_commit :create_analysis, on: :create
    before_destroy :destroy_events
    before_destroy :destroy_analysis
  end

  # Relations

  def events
    Event.where(filter)
  end

  def analysis
    Analysis.where(analysable_type: trace_type, analysable_id: id).first
  end

  def create_analysis
    Analysis.create({analysable_type: trace_type, analysable_id: id, measures: {}})
  end

  def destroy_events
    events.delete_all if events
  end

  def destroy_analysis
    analysis.destroy! if analysis
  end

  # Polymorphism

  def trace_type
    self.class.table_name.singularize.to_sym
  end

  def app_trace?
    trace_type == :app_trace
  end

  def process_trace?
    trace_type == :process_trace
  end

  def socket_trace?
    trace_type == :socket_trace
  end

  # Analysable

  def filter
    {"#{trace_type}_id": id}
  end

  def analysable_type
    trace_type
  end

  # Analysis

  def update_analysis
    analysis.update(self)
    analysis_computed ? touch : analysis_computed!
  end

  def analysis_computed!
    self.analysis_computed = true
    save!
  end

  def schedule_analysis
    if app_trace?         then AppAnalysisJob.perform_later(id)
    elsif process_trace?  then ProcessAnalysisJob.perform_later(id)
    elsif socket_trace?   then SocketAnalysisJob.perform_later(id)
    else raise
    end
  end
end
