class Job < ApplicationRecord
  belongs_to :company
  has_many :applies, dependent: :destroy
  has_many :geeks, through: :applies

  scope :active, -> { joins(:company).merge(Company.active).where(deleted: false) }

  validates :name, :place, presence: true, length: { maximum: 255 }
  validates :company_id, numericality: { only_integer: true, greater_than: 0 }, allow_nil: true
  validates_associated :company
  validate :company_is_active, if: -> { new_record? || will_save_change_to_company_id? }

  def mark_deleted!
    update!(deleted: true)
  end

  private

  def company_is_active
    errors.add(:company, "is deleted") if company&.deleted?
  end
end
