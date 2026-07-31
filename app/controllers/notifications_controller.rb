class NotificationsController < ApplicationController
  include RatfController

  before_action :set_record, only: %i[show edit update destroy mark_read]
  skip_before_action :set_record, only: :unread_count

  def index
    @records = paginate(Notification.order(created_at: :desc))
  end

  def show
  end

  def new
    @record = Notification.new
  end

  def create
    @record = Notification.new(notification_params)
    if @record.save
      render_flash(:notice, "Notification created.")
      redirect_to after_create_path(@record)
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @record.update(notification_params)
      render_flash(:notice, "Notification updated.")
      redirect_to after_update_path(@record)
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @record.destroy
    render_flash(:notice, "Notification removed.")
    redirect_to notifications_path
  end

  def mark_read
    @record.mark_as_read!
    render_flash(:notice, "Notification marked as read.")
    redirect_to notifications_path
  end

  def unread_count
    count = Notification.where(user: current_user).unread.count
    render json: { count: count }
  end

  private

  def set_record
    @record = Notification.find(params[:id])
  end

  def notification_params
    params.require(:notification).permit(:user_id, :message, :notification_type)
  end
end
