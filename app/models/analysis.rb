class Analysis
  include Mongoid::Document
  include Mongoid::Timestamps

  field :analysable_type, type: String
  field :analysable_id, type: Integer
  field :measures, type: Hash

  def update(analysable)
    measure_attr = {measures: measures.to_h}
    StatCategory.applies_to(analysable).pluck(:id).each do |stat_category_id|
      Stat.category(stat_category_id).each do |stat|
        measure_attr[:measures][stat.name] = stat.compute(analysable.filter)
        update_attributes(measure_attr)
      end
    end
  end
end
