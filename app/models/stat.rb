class Stat
	attr_reader :type, :symbol_name, :node

	def self.prop(name, node, **where)
		new(:proportion, name, node, where)
	end

	def self.cdf(name, node, **where)
		new(:cdf, name, node, where)
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
			Event.count_by_val(node, @where) 
		elsif type == :cdf then
		 	cdf(Event.vals(node, @where))
		end
	end

	def cdf(sorted_val)
		sorted_val.map do |el|
			pc = ((sorted_val.rindex { |v| v <= el } || -1.0) + 1.0) / sorted_val.size * 100.0
			[el, pc]
		end.uniq
  end
end
