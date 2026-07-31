class SchedulesController < ApplicationController
  include RatfController

  before_action :set_record, only: %i[ show edit update destroy trigger ]

  def index
    @records = paginate(Schedule.includes(:job).order(created_at: :desc))
  end

  def show
  end

  def new
    @record = Schedule.new
  end

  def create
    @record = Schedule.new(schedule_params)
    if @record.save
      render_flash(:notice, "Schedule was successfully created.")
      redirect_to after_create_path(@record)
    else
      render_flash(:alert, @record.errors.full_messages.to_sentence)
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @record.update(schedule_params)
      render_flash(:notice, "Schedule was successfully updated.")
      redirect_to after_update_path(@record)
    else
      render_flash(:alert, @record.errors.full_messages.to_sentence)
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @record.destroy
    render_flash(:notice, "Schedule was successfully deleted.")
    redirect_to schedules_path
  end

  def trigger
    @record.record_run!
    render_flash(:notice, "Schedule \"#{@record.name}\" triggered — job run recorded.")
    redirect_to schedule_path(@record)
  end

  private

  def set_record
    @record = Schedule.find(params[:id])
  end

  def schedule_params
    params.require(:schedule).permit(
      :name,
      :cron_expression,
      :enabled,
      :description,
      :job_id
    )
  end
end
