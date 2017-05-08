class DatasetSegment
  include Analysable
  attr_reader :os, :connectivity, :socket_domain, :socket_type, :remote_con,
              :network_specialized_app

  def initialize(os, connectivity)
    @os = (os.nil? ? nil : os.to_i)
    @connectivity = (connectivity.nil? ? nil : connectivity.to_i)
  end

  def events_filter
    filter = {network_specialized_app: false, remote_con: true}
    filter.merge!({os: @os}) unless @os.nil?
    filter.merge!({connectivity: @connectivity}) unless @connectivity.nil?
    filter
  end

  def analysable_type
    :dataset
  end

  def analysable_id # Create unique id based on os & con
    (os.nil? ? 0 : os+1) + (connectivity.nil? ? 0 : connectivity+1) * 100
  end

  def self.schedule_all_analysis
    (AppTrace.os.values+[nil]).each do |os|
      (AppTrace.connectivities.values+[nil]).each do |con|
        DatasetAnalysisJob.perform_later(os, con)
      end
    end
  end
end
