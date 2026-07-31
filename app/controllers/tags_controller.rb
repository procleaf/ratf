class TagsController < ApplicationController
  include RatfController

  before_action :set_record, only: %i[show edit update destroy]

  def index
    @records = paginate(Tag.order(created_at: :desc))
  end

  def show
  end

  def new
    @record = Tag.new
  end

  def create
    @record = Tag.new(tag_params)
    if @record.save
      render_flash(:notice, "Tag was successfully created.")
      redirect_to after_create_path(@record)
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @record.update(tag_params)
      render_flash(:notice, "Tag was successfully updated.")
      redirect_to after_update_path(@record)
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @record.destroy
    render_flash(:notice, "Tag was successfully deleted.")
    redirect_to tags_path
  end

  private

  def set_record
    @record = Tag.find(params[:id])
  end

  def tag_params
    params.require(:tag).permit(:name)
  end
end
