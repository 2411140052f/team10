class PagesController < ApplicationController
  before_action :require_staff, only: %i[lost_item_registration handover_registration update_lost_item_status destroy_missing_report]

  def home
    @lost_items = LostItem.includes(photo_attachment: :blob).order(found_at: :desc, created_at: :desc)

    if params[:found_at].present?
      begin
        date = Date.parse(params[:found_at])
        @lost_items = @lost_items.where(found_at: date.all_day)
      rescue Date::Error
        # Ignore malformed date filters instead of returning an error.
      end
    end
    @lost_items = @lost_items.where("found_place LIKE ?", "%#{params[:found_place]}%") if params[:found_place].present?
    @lost_items = @lost_items.where("category LIKE ?", "%#{params[:category]}%") if params[:category].present?
    case params[:sort]
    when "place"
      @lost_items = @lost_items.reorder(found_place: :asc)
    when "category"
      @lost_items = @lost_items.reorder(category: :asc)
    else
      @lost_items = @lost_items.reorder(found_at: :desc)
    end
  end

  def missing_reports
    @missing_reports = MissingReport.includes(photo_attachment: :blob).order(code: :asc)

    if params[:name].present?
      @missing_reports = @missing_reports.where("name LIKE ?", "%#{params[:name]}%")
    end
    if params[:lost_place].present?
      @missing_reports = @missing_reports.where("lost_place LIKE ?", "%#{params[:lost_place]}%")
    end
    if params[:feature].present?
      @missing_reports = @missing_reports.where("feature LIKE ?", "%#{params[:feature]}%")
    end
    if params[:lost_at].present?
      begin
        date = Date.parse(params[:lost_at])
        @missing_reports = @missing_reports.where(lost_at: date.all_day)
      rescue Date::Error
        # Ignore malformed date filters instead of returning an error.
      end
    end
    if params[:code].present?
      @missing_reports = @missing_reports.where(code: params[:code])
    end
  end

  def missing_report_registration
  end

  def create_missing_report
    @missing_report = MissingReport.new(missing_report_params)

    if @missing_report.save
      redirect_to missing_reports_path, notice: "捜索願を登録しました（ID: #{@missing_report.code}）"
    else
      flash.now[:alert] = @missing_report.errors.full_messages.to_sentence
      render :missing_report_registration, status: :unprocessable_entity
    end
  end

  def staff_login
    redirect_to lost_item_registration_path if current_staff
  end

  def create_staff_session
    username = params[:username].to_s.strip
    staff = Staff.find_by(username: username)

    if staff&.authenticate(params[:password])
      reset_session
      session[:staff_id] = staff.id
      redirect_to lost_item_registration_path
    else
      flash.now[:alert] = "ユーザー名またはパスワードが正しくありません"
      render :staff_login, status: :unprocessable_entity
    end
  end

  def destroy_staff_session
    reset_session
    redirect_to root_path, status: :see_other
  end

  def lost_item_registration
  end

  def create_lost_item
    @lost_item = LostItem.new(lost_item_params)
    @lost_item.staff = current_staff
    @lost_item.status = "受け取り前"

    if @lost_item.save
      redirect_to root_path, notice: "忘れ物を登録しました"
    else
      flash.now[:alert] = @lost_item.errors.full_messages.to_sentence
      render :lost_item_registration, status: :unprocessable_entity
    end
  end

  def handover_registration
    @lost_items = LostItem.includes(photo_attachment: :blob).order(created_at: :desc)
    @deletion_requests = DeletionRequest.includes(:missing_report).order(created_at: :desc)
  end

  def create_deletion_request
    code = params.dig(:deletion_request, :missing_report_code) ||
      params.dig(:deletion_request, :code) ||
      params[:missing_report_code] ||
      params[:code]
    report = MissingReport.find_by(code: code.to_i)

    request_params = params[:deletion_request] || params
    request_params = ActionController::Parameters.new(request_params) unless request_params.respond_to?(:permit)

    @deletion_request = DeletionRequest.new(
      missing_report: report,
      student_number: request_params[:student_number],
      name: request_params[:name]
    )

    if report && @deletion_request.save
      redirect_to missing_report_registration_path, notice: "削除申請を送信しました"
    else
      flash.now[:alert] = if report
        @deletion_request.errors.full_messages.to_sentence
      else
        "一致する捜索願IDがありません"
      end
      render :missing_report_registration, status: :unprocessable_entity
    end
  end

  def update_lost_item_status
    lost_item = LostItem.find(params[:id])

    if lost_item.update(status: "受け取り済み")
      redirect_to handover_registration_path, notice: "落とし物ID #{lost_item.id} を受け取り済みに変更しました"
    else
      redirect_to handover_registration_path, alert: "ステータスを変更できませんでした"
    end
  end

  def destroy_missing_report
    missing_report = MissingReport.find_by(code: params[:code].to_i)

    if missing_report
      missing_report.destroy!
      redirect_to handover_registration_path, notice: "捜索願ID #{params[:code]} を削除しました"
    else
      redirect_to handover_registration_path, alert: "一致する捜索願IDがありません"
    end
  end

  private

  def lost_item_params
    item_params = params[:lost_item] || params
    item_params = ActionController::Parameters.new(item_params) unless item_params.respond_to?(:permit)
    item_params.permit(:name, :found_place, :found_at, :feature, :category, :photo)
  end

  def missing_report_params
    report_params = params[:missing_report] || params
    report_params = ActionController::Parameters.new(report_params) unless report_params.respond_to?(:permit)
    report_params.permit(:name, :lost_place, :lost_at, :feature, :category, :photo)
  end
end
