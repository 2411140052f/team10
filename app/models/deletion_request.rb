class DeletionRequest < ApplicationRecord
  belongs_to :missing_report

  validates :student_number, presence: true
  validates :name, presence: true
end
