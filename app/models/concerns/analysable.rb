module Analysable
  extend ActiveSupport::Concern

  included do
    after_commit :create_analysis, on: :create
    before_destroy :destroy_analysis
  end

  def analysable_type
    self.class.table_name.singularize
  end

  def analysis
    @analysis ||= Analysis.where(analysable_type: analysable_type, analysable_id: id).first
  end

  def analysis_computed!
    self.analysis_computed = true
    self.save!
  end

  def create_analysis
    Analysis.create({
      analysable_type: analysable_type,
      analysable_id: id,
      measures: {}
    })
  end

  def destroy_analysis
    analysis.destroy! if analysis
  end

  def schedule_analysis
    AnalysisJob.perform_later(analysable_type, id)
  end

  def stat_data(stat)
    analysis ? analysis[:measures][stat.name].to_a : [] # to_a cast nil to []
  end
end

