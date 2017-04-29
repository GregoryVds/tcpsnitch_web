class Event
  include Mongoid::Document

  field :app, type: String
  field :app_trace_id, type: Integer
  field :connectivity, type: Integer
  field :details, type: Hash
  field :errno, type: String
  field :fake_call, type: Boolean
  field :index, type: Integer
  field :os, type: Integer
  field :return_value, type: Integer
  field :process_trace_id, type: Integer
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
  index({type: 1, fake_call: 1}, background: true)

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
