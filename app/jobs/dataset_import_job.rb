class DatasetImportJob < ActiveJob::Base
	queue_as :default

	def perform(dataset_id)
		dataset = Dataset.find(dataset_id)
		puts "Hello" + dataset_id	
	end
end
