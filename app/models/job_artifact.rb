class JobArtifact < ActiveRecord::Base
  belongs_to :job

  has_one_attached :file

  enum :artifact_type, { log: 0, report: 1, screenshot: 2, video: 3, data: 4 }

  validates :name, presence: true

  def human_readable_size
    return '0 B' unless file.attached?
    size = file.byte_size
    units = ['B', 'KB', 'MB', 'GB']
    unit = 0
    while size > 1024 && unit < units.length - 1
      size /= 1024.0
      unit += 1
    end
    "#{size.round(2)} #{units[unit]}"
  end
end
