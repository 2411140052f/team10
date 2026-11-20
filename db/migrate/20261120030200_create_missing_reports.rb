class CreateMissingReports < ActiveRecord::Migration[8.1]
  def change
    create_table :missing_reports do |t|
      t.integer :code, null: false
      t.string :name, null: false
      t.string :lost_place, null: false
      t.datetime :lost_at
      t.text :feature
      t.string :category

      t.timestamps
    end

    add_index :missing_reports, :code, unique: true
  end
end
