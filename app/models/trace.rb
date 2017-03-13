class Trace < ApplicationRecord
  mount_uploader :zip_file, TraceUploader
	validates :zip_file, presence: true
	validate :zip_file_contains_meta_files

#	validates :app, :connectivity, :kernel, :log, :machine, :net, :os, :zip_file, presence: true

	enum connectivity: [ :wifi, :lte, :ethernet ]
	enum os: [ :darwin, :linux ]

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

	def first_line(path)
		File.open(path, &:readline).strip
	end

end
