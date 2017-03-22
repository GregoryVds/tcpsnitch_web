class Analysis
  include Mongoid::Document

  field :measurable_type, type: String
  field :measurable_id, type: Integer

  after_create :set_analysis_computed_on_measurable

  StatComputation::STATS_DEFINITIONS.keys.each do |stat_name|
    field stat_name, type: Array
  end

  def measurable
    @measurable ||= measurable_type.classify.constantize.find(measurable_id)
  end

  def set_analysis_computed_on_measurable
    measurable.analysis_computed!
  end

  def self.compute(measurable_type, measurable_id)
    attr = {
      measurable_type: measurable_type, 
      measurable_id: measurable_id
    }
    measurable_type.classify.constantize::STATS.each do |stat| 
      attr[stat] = StatComputation.new(stat, {"#{measurable_type}_id": measurable_id}).compute
    end
    create(attr)
  end
end

