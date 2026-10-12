class Company < ApplicationRecord
  has_many :jobs, dependent: :destroy

  validates :name, :location, presence: true, length: { maximum: 255 }
end
