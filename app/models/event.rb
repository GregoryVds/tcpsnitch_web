class Event
	include Mongoid::Document
	field :app, type: String
	field :connectivity, type: Integer
	field :details, type: Hash
	field :error_str, type: String
	field :os, type: Integer
	field :return_value, type: Integer
	field :socket_num, type: Integer
	field :success, type: Boolean
	field :timestamp, type: Hash
	field :trace_id, type: Integer
	field :type, type: String
end
