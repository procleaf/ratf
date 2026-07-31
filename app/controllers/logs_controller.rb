class LogsController < ApplicationController
  include RatfController

  before_action :set_record, only: %i[show stream]

  def index
    scope = Log.order(created_at: :desc)
    if params[:q].present?
      scope = scope.where("content LIKE ?", "%#{params[:q]}%")
    end
    @records = paginate(scope)
  end

  def show
  end

  def stream
    render plain: @record.content
  end

  private

  def set_record
    @record = Log.find(params[:id])
  end
end
