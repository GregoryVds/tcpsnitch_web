module Archive
  extend ActiveSupport::Concern

  META = [:app, :app_version, :cmd, :host_id, :git_hash, :kernel, :machine,
          :net, :opt_b, :opt_f, :opt_u, :os, :version]

  included do
    mount_uploader :archive, ArchiveUploader

    validates :archive, presence: true
    validate :archive_contains_meta_files

    scope :imported, -> { where(events_imported: true) }

    after_commit :schedule_import, on: :create
  end

  def archive_is_zip
    archive.file.extension.eql? "zip"
  end

  def files_in_archive
    @files_in_archive ||= (archive_is_zip ? zip_files : targz_files)
  end

  def targz_files
    `tar -tf #{archive.file.path}`.split("\n").map{|s| s.gsub("./", "")}
  end

  def zip_files
    `zipinfo -1 #{archive.file.path}`.split("\n")
  end

  def archive_contains_meta_files
    return if errors.present?
    META.each do |f|
      unless files_in_archive.include?("meta/#{f}") then
        errors.add(:archive, "missing file 'meta/#{f}'")
      end
    end
  end

  def schedule_import
    ArchiveImportJob.perform_later(id)
  end
end
