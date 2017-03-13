class Execution < ApplicationRecord
	belongs_to :dataset

	# TODO: Validates dataset presence
	validates :app, :connectivity, :kernel, :log, :machine, :net, :os, presence: true

	enum connectivity: [ :wifi, :lte, :ethernet ]
	enum os: [ :darwin, :linux ]

	def self.first_line(path)
		File.open(path, &:readline).strip
	end

	def self.create_from_meta(meta_path)
		self.create({
			app: 					first_line(meta_path + '/app'),
			cmd:					(File.exists?(meta_path + '/cmd') ? first_line(meta_path + '/app') : nil),
			connectivity: first_line(meta_path + '/connectivity'),
			kernel: 			first_line(meta_path + '/kernel'),
			log: 					File.read(meta_path + '/log'),
			machine: 			first_line(meta_path + '/machine'),
			net: 					File.read(meta_path + '/net'),
			os: 					first_line(meta_path + '/os')
		})
	end

	def connectivity=(val)
		super(val.downcase)
	end

	def os=(val)
		super(val.downcase)
	end

end

