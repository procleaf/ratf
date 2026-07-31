class TestSuiteRunsController < ApplicationController
  include RatfController

  before_action :set_record, only: %i[show edit update destroy]

  def index
    @records = paginate(TestSuiteRun.order(created_at: :desc))
  end

  def show
  end

  def new
    @record = TestSuiteRun.new
  end

  def create
    @record = TestSuiteRun.new(test_suite_run_params)
    if @record.save
      render_flash(:notice, "Test suite run was successfully created.")
      redirect_to after_create_path(@record)
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @record.update(test_suite_run_params)
      render_flash(:notice, "Test suite run was successfully updated.")
      redirect_to after_update_path(@record)
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @record.destroy
    render_flash(:notice, "Test suite run was successfully deleted.")
    redirect_to test_suite_runs_path
  end

  private

  def set_record
    @record = TestSuiteRun.find(params[:id])
  end

  def test_suite_run_params
    params.require(:test_suite_run).permit(
      :test_suite_id, :job_run_id, :status,
      :total_tests, :passed_tests, :failed_tests,
      :skipped_tests, :errored_tests, :total_duration,
      :started_at, :ended_at
    )
  end
end
