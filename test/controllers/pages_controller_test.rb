require "test_helper"

class PagesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @staff = Staff.create!(username: "test_staff", password: "password123", role: "staff")
  end

  test "should get home" do
    get root_url
    assert_response :success
  end

  test "should get missing reports" do
    get missing_reports_url
    assert_response :success
  end

  test "missing report registration limits name and feature to 39 characters" do
    get missing_report_registration_url

    assert_response :success
    assert_select "input[name='missing_report[name]'][maxlength='39']"
    assert_select "textarea[name='missing_report[feature]'][maxlength='39']"
    assert_select "input[name='deletion_request[student_number]'][maxlength='10'][inputmode='numeric'][pattern='[0-9]{10}']"
  end

  test "deletion request ID accepts only digits" do
    get missing_report_registration_url

    assert_response :success
    assert_select "input[name='deletion_request[missing_report_code]'][type='text'][inputmode='numeric'][pattern='[0-9]*']"

    report = MissingReport.create!(name: "鍵", lost_place: "教室")
    post deletion_requests_url, params: {
      deletion_request: {
        missing_report_code: "#{report.code}abc",
        student_number: "123456",
        name: "山田 太郎"
      }
    }

    assert_response :unprocessable_entity
    assert_select "p[role='alert']", text: "捜索願IDは数字で入力してください"
    assert_empty DeletionRequest.all
  end

  test "deletion request requires exactly 10 numeric student number digits" do
    report = MissingReport.create!(name: "鍵", lost_place: "教室")

    ["123456789", "12345678901", "12345abc90"].each do |student_number|
      post deletion_requests_url, params: {
        deletion_request: {
          missing_report_code: report.code,
          student_number: student_number,
          name: "山田 太郎"
        }
      }

      assert_response :unprocessable_entity
      assert_select "p[role='alert']", text: /半角数字10桁/
    end

    assert_empty DeletionRequest.all
  end

  test "should get staff login" do
    get staff_login_url
    assert_response :success
  end

  test "should get lost item registration" do
    post staff_login_url, params: { username: "test_staff", password: "password123" }
    get lost_item_registration_url
    assert_response :success
  end

  test "should get handover registration" do
    post staff_login_url, params: { username: "test_staff", password: "password123" }
    get handover_registration_url
    assert_response :success
  end

  test "should login with valid credentials" do
    post staff_login_url, params: { username: "test_staff", password: "password123" }
    assert_redirected_to lost_item_registration_url
  end

  test "should reject invalid credentials" do
    post staff_login_url, params: { username: "test_staff", password: "wrong" }
    assert_response :unprocessable_entity
  end

  test "should log out and redirect to home" do
    post staff_login_url, params: { username: "test_staff", password: "password123" }
    delete logout_url
    assert_redirected_to root_url

    get lost_item_registration_url
    assert_redirected_to staff_login_url
  end

  test "should require login for staff pages" do
    get lost_item_registration_url
    assert_redirected_to staff_login_url
  end

  test "should register a lost item and show it on home" do
    post staff_login_url, params: { username: "test_staff", password: "password123" }
    lost_item_count = LostItem.count
    post lost_item_registration_url, params: {
      lost_item: {
        name: "黒い傘",
        found_place: "図書館",
        found_at: "2026-11-20T10:30",
        feature: "取っ手に赤いテープ",
        category: "傘"
      }
    }

    assert_redirected_to root_url
    assert_equal lost_item_count + 1, LostItem.count

    get root_url
    assert_response :success
    assert_select "h3", text: "黒い傘"
  end

  test "should register a missing report without staff login and show it in the list" do
    missing_report_count = MissingReport.count

    post missing_report_registration_url, params: {
      missing_report: {
        name: "青いペンケース",
        lost_place: "体育館",
        lost_at: "2026-11-20T09:15",
        feature: "前面に白い星マーク"
      }
    }

    assert_redirected_to missing_reports_url
    assert_equal missing_report_count + 1, MissingReport.count

    report = MissingReport.order(:code).last
    assert_equal 1, report.code if missing_report_count.zero?

    get missing_reports_url
    assert_response :success
    assert_select "h3", text: "青いペンケース"
  end

  test "should change a lost item status to handed over" do
    post staff_login_url, params: { username: "test_staff", password: "password123" }
    lost_item = LostItem.create!(
      name: "赤い帽子",
      found_place: "校門",
      found_at: "2026-11-20T08:00",
      feature: "黄色いマーク",
      status: "受け取り前",
      staff: @staff
    )

    patch lost_item_status_url(lost_item)

    assert_redirected_to handover_registration_url
    assert_equal "受け取り済み", lost_item.reload.status
  end

  test "should delete a matching missing report by id" do
    post staff_login_url, params: { username: "test_staff", password: "password123" }
    report = MissingReport.create!(
      name: "鍵",
      lost_place: "教室",
      lost_at: "2026-11-20T12:00",
      feature: "青いキーホルダー"
    )

    delete missing_report_url(report.code)

    assert_redirected_to handover_registration_url
    assert_not MissingReport.exists?(report.id)
  end

  test "should not delete a missing report when id does not match" do
    post staff_login_url, params: { username: "test_staff", password: "password123" }

    delete missing_report_url(999999)

    assert_redirected_to handover_registration_url
    follow_redirect!
    assert_select "p[role=alert]", text: "一致する捜索願IDがありません"
  end

  test "should submit a deletion request and show it on handover page" do
    report = MissingReport.create!(
      name: "鍵",
      lost_place: "校舎",
      lost_at: "2026-11-20T13:00"
    )

    post deletion_requests_url, params: {
      deletion_request: {
        missing_report_code: report.code,
        student_number: "1234567890",
        name: "山田 太郎"
      }
    }

    assert_redirected_to missing_report_registration_url
    assert_equal 1, DeletionRequest.count

    post staff_login_url, params: { username: "test_staff", password: "password123" }
    get handover_registration_url

    assert_response :success
    assert_select "p", text: "申請者学籍番号: 1234567890"
    assert_select "p", text: "申請者氏名: 山田 太郎"
  end
end
