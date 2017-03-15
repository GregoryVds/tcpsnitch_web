class Trace < ApplicationRecord
	after_commit :schedule_import, on: :create
  mount_uploader :archive, TraceUploader
	validates :archive, :workload, presence: true
	validate :archive_contains_meta_files

	# Only validate update, since at creation time, archive is not yet processed
	validates :app, :connectivity, :kernel, :machine, :os, :version, :workload, 
            presence: true, on: :update

	enum connectivity: {wifi: 0, lte: 1, ethernet: 2}
	enum os: {linux: 0, android: 1, darwin: 2}

	META = ['app', 'cmd', 'connectivity', 'kernel', 'log', 'machine', 'os', 'version']

	def os_int
		Trace.os[os]
	end

	def connectivity_int
		Trace.connectivities[connectivity]
	end

	def archive_is_zip
		archive.file.extension.eql? "zip"
	end

	def files_in_archive
		@files_in_archive ||= (archive_is_zip ? zip_files : targz_files) 
	end

	def targz_files
			`tar -tf #{archive.file.path}`.split("\n") 
	end

	def zip_files
			`zipinfo -1 #{archive.file.path}`.split("\n") 
	end

	def archive_contains_meta_files	
		return if errors
		META.each do |f|
			unless files_in_archive.include?("meta/#{f}") then
				errors.add(:archive, "missing file 'meta/#{f}'")	
			end
		end	
	end

	def schedule_import
		TraceImportJob.perform_later(id)
	end
end
