class QuantitativeAnalysisJob < ActiveJob::Base
	queue_as :default

	def perform(measurable_type, measurable_id)
		QuantitativeAnalysis.compute(measurable_type, measurable_id)
	end
end
