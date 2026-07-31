class CloudInstancesController < ApplicationController
  include RatfController

  before_action :require_login
  before_action :require_staff!
  before_action :set_record, only: %i[show edit update destroy start stop terminate]

  def index
    scope = CloudInstance.recent.joins(:cloud_provider).where(cloud_providers: { user_id: current_user.id })
    scope = scope.where("cloud_instances.name LIKE ? OR cloud_instances.instance_id LIKE ?", "%#{params[:q]}%", "%#{params[:q]}%") if params[:q].present?
    scope = scope.where(status: params[:status]) if params[:status].present?
    @records = paginate(scope)
  end

  def show; end

  def new
    @record = CloudInstance.new
  end

  def create
    @record = CloudInstance.new(instance_params)
    if @record.save
      redirect_to @record, notice: "Instance created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit; end

  def update
    if @record.update(instance_params)
      redirect_to @record, notice: "Instance updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @record.terminate!
    redirect_to cloud_instances_path, notice: "Instance terminated."
  end

  def start
    @record.start!
    redirect_to @record, notice: "Instance started."
  end

  def stop
    @record.stop!
    redirect_to @record, notice: "Instance stopped."
  end

  def terminate
    @record.terminate!
    redirect_to cloud_instances_path, notice: "Instance terminated."
  end

  private

  def set_record
    @record = CloudInstance.joins(:cloud_provider).where(cloud_providers: { user_id: current_user.id }).find(params[:id])
  end

  def instance_params
    params.require(:cloud_instance).permit(:cloud_provider_id, :instance_id, :instance_type, :name, :public_ip, :private_ip, :availability_zone, :hourly_cost)
  end
end
