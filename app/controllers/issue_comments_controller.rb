class IssueCommentsController < ApplicationController
  include RatfController

  before_action :set_issue
  before_action :set_record, only: %i[show edit update destroy]

  def index
    @records = paginate(@issue.issue_comments.includes(:user).chronological)
  end

  def show
  end

  def new
    @record = @issue.issue_comments.new
  end

  def edit
  end

  def create
    @record = @issue.issue_comments.new(issue_comment_params)
    @record.user = current_user

    if @record.save
      render_flash(:notice, "Comment was successfully created.")
      redirect_to after_create_path(@record)
    else
      render :new, status: :unprocessable_entity
    end
  end

  def update
    if @record.update(issue_comment_params)
      render_flash(:notice, "Comment was successfully updated.")
      redirect_to after_update_path(@record)
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @record.destroy
    render_flash(:notice, "Comment was successfully deleted.")
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
    @record = @issue.issue_comments.find(params[:id])
  end

  def issue_comment_params
    params.require(:issue_comment).permit(:content)
  end
end
