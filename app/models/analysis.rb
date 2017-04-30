class Analysis
  include Mongoid::Document
  include Mongoid::Timestamps

  field :analysable_type, type: String
  field :analysable_id, type: Integer
  field :os, type: Integer
  field :connectivity, type: Integer
  field :measures, type: Hash

  index({analysable_id: 1, analysable_type: 1})

  def update(analysable)
    analysable_type = analysable.analysable_type
    measure_attr = {measures: measures.to_h}
    StatCategory.applies_to(analysable_type).pluck(:id).each do |stat_category_id|
      Stat.category(stat_category_id, analysable_type).each do |stat|
        measure_attr[:measures][stat.name] = stat.compute(analysable)
        update_attributes(measure_attr)
      end
    end
  end
end
