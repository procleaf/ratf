class TestCasesController < ApplicationController
  include RatfController

  before_action :set_record, only: %i[show edit update destroy run]

  def index
    @records = paginate(TestCase.order(created_at: :desc))
  end

  def show
  end

  def new
    @record = TestCase.new
  end

  def create
    @record = TestCase.new(test_case_params)
    if @record.save
      render_flash(:notice, "Test case was successfully created.")
      redirect_to after_create_path(@record)
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @record.update(test_case_params)
      render_flash(:notice, "Test case was successfully updated.")
      redirect_to after_update_path(@record)
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @record.destroy
    render_flash(:notice, "Test case was successfully deleted.")
    redirect_to test_cases_path
  end

  # POST /test_cases/:id/run — executes the test case steps
  def run
    results = TestCaseRunner.run(@record)
    result = @record.test_results.last

    respond_to do |format|
      format.html { redirect_to @record, notice: "Test #{result&.passed? ? 'passed ✅' : 'failed ❌'} in #{result&.execution_time}s" }
      format.json { render json: {
        status: result&.status,
        execution_time: result&.execution_time,
        message: result&.message,
        steps: results.map { |r|
          { step: r.step, exit_code: r.exit_code, stdout: r.stdout, duration_ms: r.duration_ms }
        }
      }}
    end
  end

  private

  def set_record
    @record = TestCase.find(params[:id])
  end

  def test_case_params
    params.require(:test_case).permit(
      :test_suite_id, :created_by_id, :name, :description,
      :status, :priority, :test_type,
      :steps, :preconditions, :expected_results, :data,
      definition: [:steps, :preconditions, :expected_results, :data]
    )
  end
end
