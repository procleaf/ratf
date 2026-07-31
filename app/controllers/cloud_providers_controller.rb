class CloudProvidersController < ApplicationController
  include RatfController

  before_action :set_record, only: %i[show edit update destroy verify]

  def index
    @records = paginate(current_user.cloud_providers.order(created_at: :desc))
  end

  def show; end

  def new
    @record = current_user.cloud_providers.new
  end

  def create
    @record = current_user.cloud_providers.new(provider_params)
    if @record.save
      redirect_to @record, notice: "Provider created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit; end

  def update
    if @record.update(provider_params)
      redirect_to @record, notice: "Provider updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    if @record.cloud_instances.any?
      redirect_to cloud_providers_path, alert: "Cannot delete provider with active instances."
    else
      @record.destroy
      redirect_to cloud_providers_path, notice: "Provider deleted."
    end
  end

  def verify
    @record.verify!
    redirect_to @record, notice: @record.connected? ? "Connection verified." : "Connection failed."
  end

  def ecs_run
    tc = TestCase.find(params[:test_case_id])
    provider = CloudProvider.aliyun.first!
    result = EcsTestExecutor.run(test_case: tc, cloud_provider: provider)
    if result&.status == "passed"
      redirect_to tc, notice: "ECS test passed in #{result.duration_seconds}s."
    else
      redirect_to tc, alert: "ECS test failed."
    end
  rescue => e
    redirect_to test_cases_path, alert: "ECS error: #{e.message}"
  end

  private

  def set_record
    @record = current_user.cloud_providers.find(params[:id])
  end

  def provider_params
    params.require(:cloud_provider).permit(:name, :provider_type, :region, :enabled, config: {})
  end
end
