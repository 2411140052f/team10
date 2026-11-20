class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  # Changes to the importmap will invalidate the etag for HTML responses
  stale_when_importmap_changes

  helper_method :current_staff

  private

  def current_staff
    @current_staff ||= Staff.find_by(id: session[:staff_id]) if session[:staff_id]
  end

  def require_staff
    return if current_staff

    redirect_to staff_login_path, alert: "ログインが必要です"
  end
end
