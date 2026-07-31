class TestSuitesController < ApplicationController
  include RatfController

  before_action :set_record, only: %i[show edit update destroy]

  def index
    @records = paginate(TestSuite.order(created_at: :desc))
  end

  def show
  end

  def new
    @record = TestSuite.new
  end

  def create
    @record = TestSuite.new(test_suite_params)
    if @record.save
      render_flash(:notice, "Test suite was successfully created.")
      redirect_to after_create_path(@record)
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @record.update(test_suite_params)
      render_flash(:notice, "Test suite was successfully updated.")
      redirect_to after_update_path(@record)
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @record.destroy
    render_flash(:notice, "Test suite was successfully deleted.")
    redirect_to test_suites_path
  end

  private

  def set_record
    @record = TestSuite.find(params[:id])
  end

  def test_suite_params
    params.require(:test_suite).permit(
      :project_id, :name, :version, :status,
      :description, :author, :tags, :dependencies,
      metadata: [:description, :author, :tags, :dependencies]
    )
  end
end
