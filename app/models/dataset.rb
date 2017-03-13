class Dataset < ApplicationRecord
	has_many :executions, inverse_of: :dataset
	validates :name, presence: true
end
