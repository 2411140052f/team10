class MissingReport < ApplicationRecord
  has_one_attached :photo
  has_many :deletion_requests, dependent: :destroy

  validates :name, presence: true, length: { maximum: 39, message: "は39文字以内で入力してください" }
  validates :feature, length: { maximum: 39, message: "は39文字以内で入力してください" }
  validates :lost_place, presence: true

  before_create :assign_code

  private

  def assign_code
    self.code = (self.class.maximum(:code) || 0) + 1
  end
end
