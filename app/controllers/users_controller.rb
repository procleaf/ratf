class UsersController < ApplicationController
  include RatfController

  before_action :set_record, only: %i[show edit update destroy]
  before_action :require_admin!, only: %i[index new create destroy]
  before_action :authorize_edit!, only: %i[edit update]

  def index
    @records = paginate(User.order(created_at: :desc))
  end

  def show; end

  def new
    @record = User.new
  end

  def create
    @record = User.new(user_params)
    if @record.save
      render_flash(:notice, "User created.")
      redirect_to after_create_path(@record)
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit; end

  def update
    if @record.update(user_params)
      render_flash(:notice, "User updated.")
      redirect_to after_update_path(@record)
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @record.destroy
    render_flash(:notice, "User removed.")
    redirect_to users_path
  end

  private

  def set_record
    @record = User.find(params[:id])
  end

  def authorize_edit!
    return if admin? || @record == current_user
    redirect_to root_path, alert: "You can only edit your own profile."
  end

  def user_params
    permitted = [:email, :username, :password, :password_confirmation]
    permitted << :role if admin?
    params.require(:user).permit(*permitted)
  end
end
