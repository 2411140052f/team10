class Staff < ApplicationRecord
  has_secure_password
  has_many :lost_items, dependent: :restrict_with_error

  validates :username, presence: true, uniqueness: true
  validates :role, presence: true
end
