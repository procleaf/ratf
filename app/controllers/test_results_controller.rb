class TestResultsController < ApplicationController
  include RatfController

  before_action :set_record, only: %i[show edit update destroy]

  def index
    @records = paginate(TestResult.order(created_at: :desc))
  end

  def show
  end

  def new
    @record = TestResult.new
  end

  def create
    @record = TestResult.new(test_result_params)
    if @record.save
      render_flash(:notice, "Test result was successfully created.")
      redirect_to after_create_path(@record)
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @record.update(test_result_params)
      render_flash(:notice, "Test result was successfully updated.")
      redirect_to after_update_path(@record)
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @record.destroy
    render_flash(:notice, "Test result was successfully deleted.")
    redirect_to test_results_path
  end

  def export
    @records = TestResult.all
    respond_to do |format|
      format.csv { send_data @records.to_csv, filename: "test_results-#{Date.today}.csv" }
    end
  end

  private

  def set_record
    @record = TestResult.find(params[:id])
  end

  def test_result_params
    params.require(:test_result).permit(
      :job_run_id, :test_case_id, :test_suite_id, :name,
      :status, :execution_time, :message,
      :started_at, :ended_at,
      :browser, :environment, :os, :version, :tags, :custom_data,
      metadata: [:browser, :environment, :os, :version, :tags, :custom_data]
    )
  end
end
