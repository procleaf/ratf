class JobsController < ApplicationController
  include RatfController

  before_action :set_record, only: %i[ show edit update destroy ]

  def index
    @records = paginate(Job.includes(:created_by).order(created_at: :desc))
  end

  def show
  end

  def new
    @record = Job.new
  end

  def create
    @record = Job.new(job_params)
    if @record.save
      render_flash(:notice, "Job was successfully created.")
      redirect_to after_create_path(@record)
    else
      render_flash(:alert, @record.errors.full_messages.to_sentence)
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @record.update(job_params)
      render_flash(:notice, "Job was successfully updated.")
      redirect_to after_update_path(@record)
    else
      render_flash(:alert, @record.errors.full_messages.to_sentence)
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @record.destroy
    render_flash(:notice, "Job was successfully deleted.")
    redirect_to jobs_path
  end

  private

  def set_record
    @record = Job.find(params[:id])
  end

  def job_params
    params.require(:job).permit(
      :name,
      :description,
      :status,
      :priority,
      :created_by_id,
      :started_at,
      :completed_at,
      definition: {}
    )
  end
end
