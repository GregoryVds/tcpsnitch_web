module Measurable
	extend ActiveSupport::Concern

	included do
		before_destroy :destroy_quantitative_analysis
	end

	def quantitative_analysis
		@quantitative_analysis ||= QuantitativeAnalysis.where(measurable_type: measurable_type, measurable_id: id).first
	end

	def measurable_type
		self.class.table_name.singularize
	end

	def quantitative_analysis_computed!
		update_column(:quantitative_analysis_computed, true)	
	end

	def destroy_quantitative_analysis
		quantitative_analysis.destroy! if quantitative_analysis
	end

	def events_imported!
		events_imported = true
		save!
		schedule_quantitative_analysis
	end

	def schedule_quantitative_analysis
		QuantitativeAnalysisJob.perform_later(measurable_type, id) 
	end

	module ClassMethods
	end
end
