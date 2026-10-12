class Company < ApplicationRecord
  has_many :jobs, dependent: :destroy

  scope :active, -> { where(deleted: false) }

  validates :name, :location, presence: true, length: { maximum: 255 }

  def mark_deleted!
    update!(deleted: true)
  end
end
