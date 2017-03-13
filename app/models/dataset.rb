class Dataset < ApplicationRecord
	has_many :executions, inverse_of: :dataset
	validates :name, :zip_file, presence: true
  mount_uploader :zip_file, DatasetUploader
end
