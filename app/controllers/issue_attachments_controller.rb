class IssueAttachmentsController < ApplicationController
  include RatfController

  before_action :set_issue
  before_action :set_record, only: %i[show edit update destroy]

  def index
    @records = paginate(@issue.issue_attachments.order(created_at: :desc))
  end

  def show
  end

  def new
    @record = @issue.issue_attachments.new
  end

  def edit
  end

  def create
    @record = @issue.issue_attachments.new(issue_attachment_params)

    if @record.save
      render_flash(:notice, "Attachment was successfully created.")
      redirect_to after_create_path(@record)
    else
      render :new, status: :unprocessable_entity
    end
  end

  def update
    if @record.update(issue_attachment_params)
      render_flash(:notice, "Attachment was successfully updated.")
      redirect_to after_update_path(@record)
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @record.destroy
    render_flash(:notice, "Attachment was successfully deleted.")
    redirect_to issue_path(@issue)
  end

  private

  def after_create_path(record)
    [@issue, record]
  end

  def after_update_path(record)
    [@issue, record]
  end

  def set_issue
    @issue = Issue.find(params[:issue_id])
  end

  def set_record
    @record = @issue.issue_attachments.find(params[:id])
  end

  def issue_attachment_params
    params.require(:issue_attachment).permit(:file)
  end
end
