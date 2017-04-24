class DatasetAnalysis
  include Mongoid::Document
  include Mongoid::Timestamps

  field :os, type: Integer
  field :connectivity, type: Integer
  field :measures, type: Hash

  def filters
    filters = {}
    filters.merge!({os: os}) unless os.nil?
    filters.merge!({connectivity: connectivity}) unless connectivity.nil?
    filters
  end

  def update
    measure_attr = {measures: measures.to_h}
    StatCategory.applies_to(:dataset).pluck(:id).each do |stat_category_id|
      Stat.category(stat_category_id).each do |stat|
        measure_attr[:measures][stat.name] = stat.compute(filters)
        update_attributes(measure_attr)
      end
    end
  end

  def self.get(os, connectivity)
    a = where(os: os, connectivity: connectivity).first
    a ? a : create!(os: os, connectivity: connectivity, measures: {})
  end

  def self.cache_val(os, connectivity)
    where(os: os, connectivity: connectivity).pluck(:id, :updated_at)
  end

  def self.schedule_analysis
    (AppTrace.os.values+[nil]).each do |os|
      (AppTrace.connectivities.values+[nil]).each do |con|
        DatasetAnalysisJob.perform_later(os, con)
      end
    end
  end
end
