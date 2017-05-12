class Event
  include Mongoid::Document

  field :app, type: String
  field :app_trace_id, type: Integer
  field :connectivity, type: Integer
  field :details, type: Hash
  field :errno, type: String
  field :fake_call, type: Boolean
  field :index, type: Integer
  field :network_specialized_app, type: Boolean
  field :os, type: Integer
  field :remote_con, type: Boolean
  field :return_value, type: Integer
  field :process_trace_id, type: Integer
  field :socket_domain, type: Integer
  field :socket_type, type: Integer
  field :socket_trace_id, type: Integer
  field :success, type: Boolean
  field :timestamp_usec, type: Integer
  field :thread_id, type: Integer
  field :type, type: String

  # For app/process/socket analysis
  index({app_trace_id: 1, fake_call: 1, type: 1})
  index({process_trace_id: 1, fake_call: 1, type: 1})
  index({socket_trace_id: 1, fake_call: 1, type: 1})

  # For dataset analysis
  index({fake_call: 1, type: 1}, background: true) # Global
  index({fake_call: 1, network_specialized_app: 1, type: 1}, background: true) # Global filtered
  index({fake_call: 1, network_specialized_app: 1, os: 1, type: 1}, background: true) # Android vs Linux
  index({fake_call: 1, network_specialized_app: 1, os: 1, socket_domain: 1, type: 1}, background: true) # IPV4 vs IPV6
  index({fake_call: 1, network_specialized_app: 1, os: 1, socket_type: 1, type: 1}, background: true) # UDP vs TCP
  index({fake_call: 1, network_specialized_app: 1, os: 1, remote_con: 1, type: 1}, background: true) # UDP vs TCP

  # For browsing events
  index({socket_trace_id: 1, index: 1})

  def self.simple_count(filter)
    coll = collection.aggregate([
      {:$match => filter},
      {:$count => 'count'}
    ], allow_disk_use: true).to_a
    coll.empty? ? 0 : coll.first['count']
  end

  def self.count_by_group(filter, group_by)
    collection.aggregate([
      {:$match => filter},
      {:$sortByCount => "$#{group_by}"}
    ], allow_disk_use: true).map do |r|
      [r["_id"], r["count"]]
    end.reject do |val, count|
      val.nil?
    end
  end

  def self.count_distinct_node_val(filter, node)
    coll = collection.aggregate([
      {:$match => filter},
      {:$project => {node => 1}},
      {:$group => {:_id => "$#{node}"}},
      {:$count => 'count'}
    ], allow_disk_use: true).to_a
    coll.empty? ? 0 : coll.first['count']
  end

  def self.count_distinct_node_val_by_group(filter, node, group_by)
    collection.aggregate([
      {:$match => filter},
      {:$group => {
        :_id => "$#{group_by}",
        :distinct_values => {:$addToSet => "$#{node}"}
      }},
      {:$project => {
        :distinct_count => { :$size => "$distinct_values" }
      }}
    ], allow_disk_use: true).map do |r|
      [r['_id'],r['distinct_count']]
    end
  end

  def self.sum_node_val_by_group(filter, group_by, sum_node)
    collection.aggregate([
      {:$match => filter},
      {:$group => {
          :_id => "$#{group_by}",
          sum: { :$sum => "$#{sum_node}" }
      }}
    ], allow_disk_use: true).map do |r|
      [r['_id'],r['sum']]
    end
  end

  def self.timeserie(filter, node)
    collection.aggregate([
      {:$match => filter},
      {:$sort => {index: 1}},
      {:$project => {timestamp_usec: 1, node: "$#{node}"}}
    ], allow_disk_use: true).map do |r|
      [r['timestamp_usec'], r['node']]
    end
  end

  def self.timeserie_sum_node(filter, node)
    serie = timeserie(filter, node)
    return nil if serie.empty?
    first_timestamp = serie.first.first
    last_timestamp_in_serie = nil
    running_sum = 0
    serie.map do |timestamp,val|
      running_sum += val
      if last_timestamp_in_serie.nil? or ((timestamp - last_timestamp_in_serie) > 1000) # 1ms
        last_timestamp_in_serie = timestamp
        [timestamp-first_timestamp,running_sum]
      else
        nil
      end
    end.compact
  end

  def self.sum(filter, sum_node)
    coll = collection.aggregate([
      {:$match => filter},
      {:$group => {
          :_id => '',
          sum: { :$sum => "$#{sum_node}" }
      }}
    ], allow_disk_use: true).to_a
    coll.empty? ? 0 : coll.first['sum']
  end
end
