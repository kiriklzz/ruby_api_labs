class Job < ApplicationRecord
  belongs_to :company
  has_many :applies, dependent: :destroy
  has_many :geeks, through: :applies

  validates :name, :place, presence: true, length: { maximum: 255 }
  validates :company_id, numericality: { only_integer: true, greater_than: 0 }, allow_nil: true
  validates_associated :company
end
