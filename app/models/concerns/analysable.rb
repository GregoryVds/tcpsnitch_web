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
    if analysable_type.eql?("app_trace")
      AppAnalysisJob.perform_later(analysable_type, id)
    elsif analysable_type.eql?("process_trace")
      ProcessAnalysisJob.perform_later(analysable_type, id)
    else
      SocketAnalysisJob.perform_later(analysable_type, id)
    end
  end

  def stat_data(stat)
    return nil unless analysis
    data = analysis[:measures][stat.name]
    if stat.collection?
      data.nil? or data.empty? ? nil : data # We don't want an empty array, but nil.
    else
      data
    end
  end
end

