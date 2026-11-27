require "test_helper"

class MissingReportTest < ActiveSupport::TestCase
  test "allows names and features up to 39 characters" do
    report = MissingReport.new(name: "a" * 39, lost_place: "教室", feature: "b" * 39)

    assert report.valid?
  end

  test "rejects names and features with 40 characters" do
    report = MissingReport.new(name: "a" * 40, lost_place: "教室", feature: "b" * 40)

    assert_not report.valid?
    assert report.errors.of_kind?(:name, :too_long)
    assert report.errors.of_kind?(:feature, :too_long)
  end
end
