class Event
  include Mongoid::Document

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

  def self.count_by_val(node, **match)
    collection.aggregate([
      {:$match => match},
      {:$sortByCount => "$#{node}"}
    ]).map do |r|
      [r["_id"], r["count"]]
    end
  end

  # Event.sum_by_group("type", "details.bytes", type: {:$in => ['read', 'write']} ).to_a
  def self.sum_by_group(group_node, sum_node, **match)
    collection.aggregate([ 
      {:$match => match}, 
      {:$group => {
          _id: "$#{group_node}",
          sum: { :$sum => "$#{sum_node}" } 
        }
      }
    ]).map do |r|
      [r["_id"], r["sum"]]
    end
  end

  def self.vals(node, **match)
    collection.aggregate([ 
      {:$match => match}, 
      {:$project => {node => 1}},
      {:$sort => {node => 1}}
    ]).map do |r|
      node_val(r, node)
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
