class CommentsController < ApplicationController
  before_action :set_comment, only: [:destroy]
  before_action :messageAll

  def create
    @comment = Comment.new(comment_params)
      if @comment.save
        redirect_to :back
      end
  end

  def destroy
    @comment.destroy
    redirect_to :back
  end


  private
    # Use callbacks to share common setup or constraints between actions.
    def set_comment
      @comment = Comment.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def comment_params
      params.require(:comment).permit(:content, :user_id, :project_id)
    end

end
