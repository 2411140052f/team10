class LostItem < ApplicationRecord
  belongs_to :staff
  has_one_attached :photo

  validates :name, presence: true
  validates :found_place, presence: true
end
