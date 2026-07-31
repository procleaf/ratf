class WikiPagesController < ApplicationController
  include RatfController

  before_action :set_record, only: %i[show edit update destroy]

  def index
    @records = WikiPage.includes(:author).order(updated_at: :desc)
    if params[:q].present?
      @records = @records.where("title LIKE ? OR body LIKE ?", "%#{params[:q]}%", "%#{params[:q]}%")
    end
    @records = paginate(@records)
  end

  def show; end

  def new
    @record = WikiPage.new
  end

  def create
    @record = WikiPage.new(page_params)
    @record.author = current_user
    if @record.save
      redirect_to @record, notice: "Page created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit; end

  def update
    if @record.update(page_params)
      redirect_to @record, notice: "Page updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @record.destroy
    redirect_to wiki_pages_path, notice: "Page deleted."
  end

  private

  def set_record
    @record = WikiPage.find(params[:id])
  end

  def page_params
    params.require(:wiki_page).permit(:title, :body, :tags)
  end
end
