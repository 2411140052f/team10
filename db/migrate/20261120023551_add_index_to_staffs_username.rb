class AddIndexToStaffsUsername < ActiveRecord::Migration[8.1]
  def change
    add_index :staffs, :username, unique: true
  end
end
