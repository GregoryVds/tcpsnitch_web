class Analysis
  include Mongoid::Document

  field :analysable_type, type: String
  field :analysable_id, type: Integer
  field :measures, type: Hash

  def analysable
    @analysable ||= analysable_type.classify.constantize.find(analysable_id)
  end

  def self.compute(analysable_type, analysable_id)
    analysable = analysable_type.classify.constantize.find(analysable_id)
    attr = {measures: {}}
    Stat.all.each do |stat|
      attr[:measures][stat.name] = stat.compute(analysable.filter)
      analysable.analysis.update_attributes(attr)
    end
    analysable.analysis_computed!
  end
end

