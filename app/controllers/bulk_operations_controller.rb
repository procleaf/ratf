class BulkOperationsController < ApplicationController
  include RatfController

  def create
    model = params[:model].constantize
    ids = params[:ids].to_s.split(",").map(&:strip).reject(&:blank?)
    action = params[:bulk_action]

    if ids.empty?
      redirect_back fallback_location: root_path, alert: "No records selected."
      return
    end

    case action
    when "delete"
      model.where(id: ids).destroy_all
      redirect_back fallback_location: root_path, notice: "Deleted #{ids.size} #{params[:model].underscore.pluralize}."
    when "archive"
      if model.respond_to?(:statuses) && model.statuses.key?("archived")
        model.where(id: ids).update_all(status: model.statuses[:archived])
        redirect_back fallback_location: root_path, notice: "Archived #{ids.size} records."
      else
        redirect_back fallback_location: root_path, alert: "Archive not supported for #{params[:model]}."
      end
    else
      redirect_back fallback_location: root_path, alert: "Unknown action: #{action}."
    end
  end
end
