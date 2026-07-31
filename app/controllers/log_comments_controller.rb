class LogCommentsController < ApplicationController
  include RatfController

  before_action :set_log

  def create
    @comment = @log.log_comments.new(comment_params)
    @comment.user = current_user
    if @comment.save
      respond_to do |format|
        format.turbo_stream
        format.html { redirect_to @log, notice: "Comment added." }
      end
    else
      respond_to do |format|
        format.html { redirect_to @log, alert: "Comment cannot be blank." }
      end
    end
  end

  def destroy
    @comment = @log.log_comments.find(params[:id])
    if @comment.user == current_user || current_user.admin?
      @comment.destroy
      redirect_to @log, notice: "Comment deleted."
    else
      redirect_to @log, alert: "Not authorized."
    end
  end

  private

  def set_log
    @log = Log.find(params[:log_id])
  end

  def comment_params
    params.require(:log_comment).permit(:content)
  end
end
