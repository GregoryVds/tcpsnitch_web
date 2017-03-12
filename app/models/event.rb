class Event
	include Mongoid::Document

	field :execution_id, type: Integer
	field :dataset_id, type: Integer
	field :socket_id, type: Integer
	field :os, type: String
	field :kernel, type: String
	field :libc, type: String
	field :application, type: String
	field :connectivity, type: String  # TODO: Enum
end
