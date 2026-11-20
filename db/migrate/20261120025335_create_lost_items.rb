class CreateLostItems < ActiveRecord::Migration[8.1]
  def change
    create_table :lost_items do |t|
      t.string :name, null: false
      t.string :found_place, null: false
      t.datetime :found_at
      t.text :feature
      t.string :category
      t.string :status
      t.references :staff, null: false, foreign_key: true

      t.timestamps
    end
  end
end
