# frozen_string_literal: true
# RBAC — Role-Based Access Control concern
# Requires `current_user` from ApplicationController
module Authorizable
  extend ActiveSupport::Concern

  included do
    helper_method :can?, :admin?, :manager?, :staff?
  end

  # ── Role Checks ─────────────────────────────────────────────
  def admin?
    current_user&.admin?
  end

  def manager?
    current_user&.manager?
  end

  def staff?
    current_user&.staff?
  end

  # ── Permission Checks ───────────────────────────────────────
  def can?(action, resource = nil)
    return false unless current_user
    return true if admin?  # admin can do anything

    case action
    when :manage_users, :view_audit_log, :manage_cloud, :manage_settings
      admin?
      staff?
    when :create_job, :create_test_case, :create_issue
      true  # any authenticated user
    when :edit_resource
      resource ? (admin? || resource.created_by == current_user || manager?) : staff?
    when :delete_resource
      resource ? (admin? || resource.created_by == current_user) : admin?
    when :view_all
      true
    else
      staff?  # default: staff can do things users can't
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

  def authorize!(action, resource = nil)
    return if can?(action, resource)
    redirect_to root_path, alert: "You are not authorized to perform this action."
  end
end
