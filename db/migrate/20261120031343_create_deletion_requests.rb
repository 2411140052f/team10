class CreateDeletionRequests < ActiveRecord::Migration[8.1]
  def change
    create_table :deletion_requests do |t|
      t.references :missing_report, null: false, foreign_key: true
      t.string :student_number, null: false
      t.string :name, null: false

      t.timestamps
    end
  end
end
