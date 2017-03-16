class Stat
	attr_reader :type, :symbol_name, :node

	def self.prop(name, node, **where)
		new(:proportion, name, node, where)
	end

	def initialize(type, symbol_name, node, **where)
		@type = type
		@symbol_name = symbol_name		
		@node = node
		@where = where
	end

	def db_name
		symbol_name.to_s
	end

	def name
		db_name.humanize
	end

	def set_filter(filter)
		@where.merge!(filter)
		self
	end

	def compute
		if type == :proportion then
			Event.proportions(node, @where) 
		end
	end
end
