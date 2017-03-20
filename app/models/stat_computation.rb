class StatComputation
	def initialize(stat_definition, trace_filters)
		@stat = stat_definition
		@where = @stat.event_filters.merge(trace_filters)
	end

	def compute
		if @stat.type == :proportion then
			Event.count_by_val(@stat.node, @where) 
		elsif @stat.type == :cdf then
		 	cdf(Event.vals(@stat.node, @where))
		end
	end

	def cdf(sorted_val)
		sorted_val.map do |el|
			pc = ((sorted_val.rindex { |v| v <= el } || -1.0) + 1.0) / sorted_val.size * 100.0
			[el, pc]
		end.uniq
  end
end

