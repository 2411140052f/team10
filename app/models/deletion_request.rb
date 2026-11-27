class DeletionRequest < ApplicationRecord
  belongs_to :missing_report

  validates :student_number, presence: true
  validates :student_number, format: { with: /\A[0-9]{10}\z/, message: "は半角数字10桁で入力してください" }
  validates :name, presence: true
end
