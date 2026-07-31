module RatfController
  extend ActiveSupport::Concern

  included do
    before_action :require_login
    before_action :set_pagination_defaults
    helper_method :paginate
    helper_method :current_user, :logged_in?, :admin?, :staff?, :can?
  end

  # ── Role Checks ─────────────────────────────────────────────
  def admin?
    current_user&.admin?
  end

  def staff?
    current_user&.staff?
  end

  # ── Permission Check ────────────────────────────────────────
  def can?(action, resource = nil)
    return false unless current_user
    return true if admin?

    case action
    when :manage, :manage_users, :manage_cloud, :manage_settings
      admin?
      staff?
    when :read
      true  # any authenticated user can read
    else
      staff?
    end
  end

  # ── Enforcement ─────────────────────────────────────────────
  def require_admin!
    return if admin?
    redirect_to root_path, alert: "Admin access required."
  end

  def require_staff!
    return if staff?
    redirect_to root_path, alert: "Staff access required."
  end

  private

  def set_pagination_defaults
    @page = [params[:page].to_i, 1].max
    @per_page = [(params[:per_page] || 25).to_i, 100].min
  end

  def paginate(scope)
    scope.limit(@per_page).offset((@page - 1) * @per_page)
  end

  def after_create_path(record)
    url_for(record)
  end

  def after_update_path(record)
    url_for(record)
  end

  def render_flash(type, message)
    flash[type] = message
  end
end
