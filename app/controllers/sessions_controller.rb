class SessionsController < ApplicationController
  skip_before_action :require_login, only: %i[new create]
  layout "centered"

  def new
    redirect_to root_path if logged_in?
  end

  def create
    user = User.find_by(email: params[:email])
    if user&.authenticate(params[:password])
      session[:user_id] = user.id
      user.update!(last_active_at: Time.now)
      redirect_to root_path, notice: "Welcome back, #{user.username}!"
    else
      flash.now[:alert] = "Invalid email or password."
      render :new, status: :unprocessable_entity
    end
  end

  def destroy
    session[:user_id] = nil
    redirect_to login_path, notice: "Logged out."
  end
end
