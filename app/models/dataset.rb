class Dataset < ApplicationRecord
	has_many :executions, inverse_of: :dataset
	validates :name, :zip_file, presence: true
  mount_uploader :zip_file, DatasetUploader
	validate :zip_file_contains_meta_files

	META_FILES = ['os','log','app','kernel','connectivity','machine','net','cmd']

	def files_in_zip
		@files_in_zip ||= zip_file.file.extension.eql?("tar.gz") ? targz_files : zip_files 
	end

	def targz_files
			`tar -tf #{zip_file.file.path}`.split("\n").map do |f| 
				f.sub!("./", "") # tar -t prepends "./" to filename, we remove it.
			end.reject(&:empty?) # Also adds "./" which becomes "", we remove it.
	end

	def zip_files
			`zipinfo -1 #{zip_file.file.path}`.split("\n") 
	end

	def zip_file_contains_meta_files	
		META_FILES.each do |f|
			unless files_in_zip.include?("meta/#{f}") then
				errors.add(:zip_file, "missing file 'meta/#{f}'")	
			end
		end	
	end
end
