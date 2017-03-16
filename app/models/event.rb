class Event
	include Mongoid::Document
	field :app, type: String
	field :connectivity, type: Integer
	field :details, type: Hash
	field :error_str, type: String
	field :os, type: Integer
	field :return_value, type: Integer
	field :socket_trace_id, type: Integer
	field :success, type: Boolean
	field :timestamp, type: Hash
	field :app_trace_id, type: Integer
	field :type, type: String

	before_create :create_socket_trace 

	def create_socket_trace
		if type.eql? 'socket' then
			sock = SocketTrace.create(app_trace_id: app_trace_id, socket_type: details["type"])
			self.socket_trace_id = sock.id
		end
	end

	def self.count_by_val(node, **match)
		collection.aggregate([ 
			{:$match => match}, 
			{:$sortByCount => "$#{node}"}
		]).map do |r|
			[r["_id"], r["count"]]
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
