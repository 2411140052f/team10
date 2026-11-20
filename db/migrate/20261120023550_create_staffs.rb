class CreateStaffs < ActiveRecord::Migration[8.1]
  def change
    create_table :staffs do |t|
      t.string :username, null: false
      t.string :password_digest, null: false
      t.string :role, null: false, default: "staff"

      t.timestamps
    end
  end
end
