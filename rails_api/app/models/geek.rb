class Geek < ApplicationRecord
  has_many :applies, dependent: :destroy
  has_many :jobs, through: :applies

  validates :name, :stack, presence: true, length: { maximum: 255 }
end
