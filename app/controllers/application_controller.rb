class ApplicationController < ActionController::Base
  include Authorizable

  # Changes to the importmap will invalidate the etag for HTML responses
  stale_when_importmap_changes

  around_action :switch_locale
  before_action :require_login
  before_action :track_visit

  helper_method :current_user, :logged_in?

  private

  def switch_locale(&action)
    locale = params[:locale] || cookies[:locale] || extract_locale_from_header || I18n.default_locale
    locale = I18n.available_locales.include?(locale.to_sym) ? locale : I18n.default_locale
    cookies[:locale] = locale
    I18n.with_locale(locale, &action)
  end

  def extract_locale_from_header
    return nil unless request.env["HTTP_ACCEPT_LANGUAGE"]
    request.env["HTTP_ACCEPT_LANGUAGE"].scan(/^[a-z]{2}/).first
  end

  def default_url_options
    { locale: I18n.locale }
  end

  def current_user
    @current_user ||= User.find_by(id: session[:user_id])
  end

  def logged_in?
    current_user.present?
  end

  def track_visit
    return unless logged_in?
    session_key = "last_visit_tracked_#{current_user.id}"
    last_tracked = session[session_key]
    now = Time.current
    if last_tracked.nil? || now - Time.parse(last_tracked.to_s) > 60
      current_user.update_column(:last_active_at, now)
      session[session_key] = now.to_s
    end
  rescue => e
    Rails.logger.warn "track_visit failed: #{e.message}"
  end

  def require_login
    unless logged_in?
      redirect_to login_path, alert: "Please sign in."
    end
  end
end
