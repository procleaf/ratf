class JobArtifactsController < ApplicationController
  include RatfController

  before_action :set_record, only: %i[ show edit update destroy ]

  def index
    @records = paginate(JobArtifact.includes(:job).order(created_at: :desc))
  end

  def show
  end

  def new
    @record = JobArtifact.new
  end

  def create
    @record = JobArtifact.new(job_artifact_params)
    if @record.save
      render_flash(:notice, "Job artifact was successfully created.")
      redirect_to after_create_path(@record)
    else
      render_flash(:alert, @record.errors.full_messages.to_sentence)
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @record.update(job_artifact_params)
      render_flash(:notice, "Job artifact was successfully updated.")
      redirect_to after_update_path(@record)
    else
      render_flash(:alert, @record.errors.full_messages.to_sentence)
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @record.destroy
    render_flash(:notice, "Job artifact was successfully deleted.")
    redirect_to job_artifacts_path
  end

  private

  def set_record
    @record = JobArtifact.find(params[:id])
  end

  def job_artifact_params
    params.require(:job_artifact).permit(
      :job_id,
      :name,
      :artifact_type,
      :file
    )
  end
end
