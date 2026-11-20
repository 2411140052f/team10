require "test_helper"

class StaffTest < ActiveSupport::TestCase
  test "authenticates with a correct password" do
    staff = Staff.create!(username: "staff_model", password: "secret123", role: "staff")

    assert staff.authenticate("secret123")
    assert_not staff.authenticate("wrong")
  end

  test "requires a unique username" do
    Staff.create!(username: "unique_staff", password: "secret123", role: "staff")

    duplicate = Staff.new(username: "unique_staff", password: "secret123", role: "staff")
    assert_not duplicate.valid?
  end
end
