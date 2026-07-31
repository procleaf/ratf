class ApiTokensController < ApplicationController
  include RatfController

  before_action :set_record, only: %i[ show edit update destroy ]

  def index
    @records = paginate(ApiToken.includes(:user).order(created_at: :desc))
  end

  def show
  end

  def new
    @record = ApiToken.new
  end

  def create
    @record = ApiToken.new(api_token_params)
    if @record.save
      render_flash(:notice, "Token created. Save this token — it won't be shown again: #{@record.raw_token}")
      redirect_to after_create_path(@record)
    else
      render_flash(:alert, @record.errors.full_messages.to_sentence)
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @record.update(api_token_params)
      render_flash(:notice, "API Token was successfully updated.")
      redirect_to after_update_path(@record)
    else
      render_flash(:alert, @record.errors.full_messages.to_sentence)
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @record.destroy
    render_flash(:notice, "API Token was successfully deleted.")
    redirect_to api_tokens_path
  end

  private

  def set_record
    @record = ApiToken.find(params[:id])
  end

  def api_token_params
    params.require(:api_token).permit(
      :name,
      :expires_at,
      :user_id
    )
  end
end
