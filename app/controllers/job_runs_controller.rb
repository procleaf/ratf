class JobRunsController < ApplicationController
  include RatfController

  before_action :set_record, only: %i[ show edit update destroy ]

  def index
  end

  def show
  end

  def new
    @record = JobRun.new
  end

  def create
    @record = JobRun.new(job_run_params)
    if @record.save
      render_flash(:notice, "Job run was successfully created.")
      redirect_to after_create_path(@record)
    else
      render_flash(:alert, @record.errors.full_messages.to_sentence)
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @record.update(job_run_params)
      render_flash(:notice, "Job run was successfully updated.")
      redirect_to after_update_path(@record)
    else
      render_flash(:alert, @record.errors.full_messages.to_sentence)
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @record.destroy
    render_flash(:notice, "Job run was successfully deleted.")
    redirect_to job_runs_path
  end

  private

  def set_record
    @record = JobRun.find(params[:id])
  end

  def job_run_params
    params.require(:job_run).permit(
      :job_id,
      :status,
      :started_at,
      :completed_at
    )
  end
end
