class AppTrace < ActiveRecord::Base
  include Measurable

  META = [:app, :app_version, :cmd, :host_id, :git_hash, :kernel, :machine,
          :net, :opt_a, :opt_b, :opt_c, :opt_d, :opt_f, :opt_l, :opt_n, :opt_t,
          :opt_u, :opt_v, :os, :version]

  mount_uploader :archive, TraceUploader

  enum connectivity: {wifi: 0, lte: 1, ethernet: 2}
  enum os: {linux: 0, android: 1, darwin: 2}

  has_many :process_traces, inverse_of: :app_trace, dependent: :destroy
  has_many :socket_traces, inverse_of: :app_trace

  validates :archive, presence: true
  validate :archive_contains_meta_files
  # At creation time, archive is not yet processed
  META.each do |meta|
    validates meta, presence: true, on: :update
  end

  scope :imported, -> { where(events_imported: true) }

  after_commit :schedule_import, on: :create

  def os_int
    AppTrace.os[os]
  end

  def connectivity_int
    AppTrace.connectivities[connectivity]
  end

  def to_s
    "Trace for #{app.capitalize} on #{os.capitalize}"
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
    TraceImportJob.perform_later(id)
  end
end
