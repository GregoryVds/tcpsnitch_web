class Event
  include Mongoid::Document
  include Mongoid::Timestamps

  field :app, type: String
  field :app_trace_id, type: Integer
  field :connectivity, type: Integer
  field :details, type: Hash
  field :errno, type: String
  field :index, type: Integer
  field :fake_call, type: Boolean
  field :os, type: Integer
  field :return_value, type: Integer
  field :process_trace_id, type: Integer
  field :socket_trace_id, type: Integer
  field :success, type: Boolean
  field :timestamp_usec, type: Integer
  field :thread_id, type: Integer
  field :type, type: String

  index({app_trace_id: 1})
  index({process_trace_id: 1})
  index({socket_trace_id: 1})
  index({socket_trace_id: 1, index: 1})

  def self.count_by_group(match, group_by)
    collection.aggregate([
      {:$match => match},
      {:$sortByCount => "$#{group_by}"}
    ], allow_disk_use: true).map do |r|
      [r["_id"], r["count"]]
    end.reject do |val, count|
      val.nil?
    end
  end

  def self.sum(match, sum_node)
    coll = collection.aggregate([
      {:$match => match},
      {:$group => {
          :_id => '',
          sum: { :$sum => "$#{sum_node}" }
      }}
    ], allow_disk_use: true).to_a
    coll.empty? ? 0 : coll.first['sum']
  end

  def self.sum_for_filters(match, sum_node, filters)
    filters.map do |filter_name, filter|
      [filter_name, sum(match.merge(filter), sum_node)]
    end
  end

  def self.sum_by_group(match, group_by, sum_node)
    collection.aggregate([
      {:$match => match},
      {:$group => {
          :_id => "$#{group_by}",
          sum: { :$sum => "$#{sum_node}" }
      }}
    ], allow_disk_use: true).map do |r|
      [r['_id'],r['sum']]
    end
  end

  def self.vals(match, node)
    collection.aggregate([
      {:$match => match},
      {:$project => {node => 1}},
      {:$sort => {node => 1}}
    ], allow_disk_use: true).map do |r|
      node_val(r, node)
    end
  end

  def self.count(match)
    coll = collection.aggregate([
      {:$match => match},
      {:$count => 'count'}
    ], allow_disk_use: true).to_a
    coll.empty? ? 0 : coll.first['count']
  end

  def self.count_distinct(match, node)
    collection.aggregate([
      {:$match => match},
      {:$project => {node => 1}},
      {:$group => {:_id => "$#{node}"}},
      {:$count => 'count'}
    ], allow_disk_use: true).first['count']
  end

  def self.count_distinct_by_group(match, node, group_by)
    collection.aggregate([
      {:$match => match},
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

  # Helpers to access path in hash
  def self.node_val(hash, path)
    val_for(hash, keys_from_path(path))
  end

  def self.val_for(hash, keys)
    keys.reduce(hash) { |h, key| h[key] }
  end

  def self.keys_from_path(path)
    path.split('.').collect(&:to_sym)
  end
end
