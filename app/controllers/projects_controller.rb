class ProjectsController < ApplicationController
  include RatfController

  before_action :set_record, only: %i[show edit update destroy]

  def index
    @records = paginate(Project.order(created_at: :desc))
  end

  def show
  end

  def new
    @record = Project.new
  end

  def create
    @record = Project.new(project_params)
    if @record.save
      render_flash(:notice, "Project was successfully created.")
      redirect_to after_create_path(@record)
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @record.update(project_params)
      render_flash(:notice, "Project was successfully updated.")
      redirect_to after_update_path(@record)
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @record.destroy
    render_flash(:notice, "Project was successfully deleted.")
    redirect_to projects_path
  end

  private

  def set_record
    @record = Project.find(params[:id])
  end

  def project_params
    params.require(:project).permit(:name, :description, :archived_at)
  end
end
