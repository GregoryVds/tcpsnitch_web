module Measurable
  extend ActiveSupport::Concern

  included do
    before_destroy :destroy_analysis
    before_destroy :destroy_events
  end

  def analysis
    @analysis ||= Analysis.where(measurable_type: measurable_type, measurable_id: id).first
  end

  def events
    @events ||= Event.where(filter)
  end

  def measurable_type
    self.class.table_name.singularize
  end

  def filter
    {"#{measurable_type}_id": id}
  end

  def analysis_computed!
    update_column(:analysis_computed, true)
  end

  def destroy_analysis
    analysis.destroy! if analysis
  end

  def destroy_events
    events.delete_all if events
  end

  def events_imported!
    self.events_imported = true
    save!
    schedule_analysis
  end

  def schedule_analysis
    AnalysisJob.perform_later(measurable_type, id) 
  end

  def stats
    self.class.stats
  end

  module ClassMethods
    def stats
      Stat.where("apply_to_#{measurable_type}" => true)
    end

    def measurable_type
      table_name.singularize
    end
  end
end
