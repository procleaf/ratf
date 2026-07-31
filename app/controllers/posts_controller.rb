class PostsController < ApplicationController
  include RatfController

  before_action :set_record, only: %i[show edit update destroy]

  def index
    @records = paginate(Post.includes(:user).order(created_at: :desc))
  end

  def show
  end

  def new
    @record = Post.new
  end

  def edit
  end

  def create
    @record = Post.new(post_params)
    @record.user = current_user

    if @record.save
      render_flash(:notice, "Post was successfully created.")
      redirect_to after_create_path(@record)
    else
      render :new, status: :unprocessable_entity
    end
  end

  def update
    if @record.update(post_params)
      render_flash(:notice, "Post was successfully updated.")
      redirect_to after_update_path(@record)
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @record.destroy
    render_flash(:notice, "Post was successfully deleted.")
    redirect_to posts_path
  end

  private

  def set_record
    @record = Post.find(params[:id])
  end

  def post_params
    params.require(:post).permit(:title, :content)
  end
end
