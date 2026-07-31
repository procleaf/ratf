class RegistrationsController < ApplicationController
  skip_before_action :require_login
  layout "centered"

  def new
    @user = User.new
  end

  def create
    @user = User.new(registration_params)
    @user.role = :user
    @user.send_welcome_message = true

    if @user.save
      session[:user_id] = @user.id
      AuditLog.track!(user: @user, action: "register")
      redirect_to root_path, notice: "Welcome to RATF, #{@user.username}!"
    else
      render :new, status: :unprocessable_entity
    end
  end

  private

  def registration_params
    params.require(:user).permit(:email, :username, :password, :password_confirmation)
  end
end
