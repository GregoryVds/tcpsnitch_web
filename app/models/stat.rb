class Stat
	attr_reader :type, :symbol_name, :node, :event_filters

	def self.prop(name, node, **event_filters)
		new(:proportion, name, node, event_filters)
	end

	def self.cdf(name, node, **event_filters)
		new(:cdf, name, node, event_filters)
	end

	def initialize(type, symbol_name, node, **event_filters)
		@type = type
		@symbol_name = symbol_name		
		@node = node
		@event_filters = event_filters
	end

	def db_name
		symbol_name.to_s
	end

	def name
		db_name.humanize
	end
end
