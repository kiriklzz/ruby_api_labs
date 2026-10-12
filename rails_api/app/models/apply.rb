class Apply < ApplicationRecord
  belongs_to :job
  belongs_to :geek

  validates :job_id, :geek_id, numericality: { only_integer: true, greater_than: 0 }, allow_nil: true
  validates :read, :invited, inclusion: { in: [true, false] }
  validates_associated :job, :geek
  validate :job_is_active, if: -> { new_record? || will_save_change_to_job_id? }

  private

  def job_is_active
    errors.add(:job, "is deleted") if job&.deleted? || job&.company&.deleted?
  end
end
