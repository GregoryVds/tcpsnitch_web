class Analysis
  include Mongoid::Document

  field :measurable_type, type: String
  field :measurable_id, type: Integer
  field :measures, type: Hash

  after_create :set_analysis_computed_on_measurable

  def measurable
    @measurable ||= measurable_type.classify.constantize.find(measurable_id)
  end

  def set_analysis_computed_on_measurable
    measurable.analysis_computed!
  end

  def self.compute(measurable_type, measurable_id)
    measurable = measurable_type.classify.constantize.find(measurable_id)
    attr = {
      measurable_type: measurable_type,
      measurable_id: measurable_id,
      measures: {}
    }
    measurable.class.stats.each do |stat|
      attr[:measures][stat.name] = stat.compute(measurable)
    end
    create(attr)
  end
end

