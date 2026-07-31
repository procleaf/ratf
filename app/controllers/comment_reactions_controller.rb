class CommentReactionsController < ApplicationController
  include RatfController

  before_action :set_comment

  # POST /issues/:issue_id/comments/:comment_id/reactions
  def create
    reaction = @comment.comment_reactions.find_or_create_by!(user: current_user, emoji: params[:emoji])
    render json: { count: @comment.comment_reactions.where(emoji: params[:emoji]).count, emoji: params[:emoji] }
  end

  # DELETE /issues/:issue_id/comments/:comment_id/reactions
  def destroy
    @comment.comment_reactions.where(user: current_user, emoji: params[:emoji]).destroy_all
    render json: { count: @comment.comment_reactions.where(emoji: params[:emoji]).count, emoji: params[:emoji] }
  end

  private

  def set_comment
    @comment = IssueComment.find(params[:issue_comment_id])
  end
end
