class IssuesController < ApplicationController
  include RatfController

  before_action :set_record, only: %i[show edit update destroy]

  def index
    @records = paginate(Issue.includes(:reported_by, :assigned_to).order(created_at: :desc))
  end

  def show
    @comments = @record.issue_comments.includes(:user).chronological
  end

  def new
    @record = Issue.new
  end

  def edit
  end

  def create
    @record = Issue.new(issue_params)
    @record.reported_by = current_user

    if @record.save
      render_flash(:notice, "Issue was successfully created.")
      redirect_to after_create_path(@record)
    else
      render :new, status: :unprocessable_entity
    end
  end

  def update
    if @record.update(issue_params)
      render_flash(:notice, "Issue was successfully updated.")
      redirect_to after_update_path(@record)
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def reassign
    @record = Issue.find(params[:id])
    updates = {}
    updates[:status] = params[:status] if params[:status].present?
    updates[:assigned_to_id] = params[:assigned_to_id] if params[:assigned_to_id].present?
    if @record.update(updates)
      redirect_to @record, notice: "Issue updated."
    else
      redirect_to @record, alert: "Update failed."
    end
  end

  def destroy
    @record.destroy
    render_flash(:notice, "Issue was successfully deleted.")
    redirect_to issues_path
  end

  private

  def set_record
    @record = Issue.find(params[:id])
  end

  def issue_params
    params.require(:issue).permit(
      :title, :description, :status, :severity, :urgency, :issue_type,
      :test_case_id, :test_result_id, :assigned_to_id
    )
  end
end
