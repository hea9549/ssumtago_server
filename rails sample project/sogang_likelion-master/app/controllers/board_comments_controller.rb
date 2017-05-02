class BoardCommentsController < ApplicationController
  before_action :set_board_comment, only: [:show, :edit, :update, :destroy]

  # GET /board_comments
  # GET /board_comments.json
  def index
    @board_comments = BoardComment.all
  end

  # GET /board_comments/1
  # GET /board_comments/1.json
  def show
  end

  # GET /board_comments/new
  def new
    @board_comment = BoardComment.new
  end

  # GET /board_comments/1/edit
  def edit
  end

  # POST /board_comments
  # POST /board_comments.json
  def create
    @board_comment = BoardComment.new(board_comment_params)

    if @board_comment.save
      redirect_to :back
    end
  end

  # PATCH/PUT /board_comments/1
  # PATCH/PUT /board_comments/1.json
  def update
    respond_to do |format|
      if @board_comment.update(board_comment_params)
        format.html { redirect_to @board_comment, notice: 'Board comment was successfully updated.' }
        format.json { render :show, status: :ok, location: @board_comment }
      else
        format.html { render :edit }
        format.json { render json: @board_comment.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /board_comments/1
  # DELETE /board_comments/1.json
  def destroy
    @board_comment.destroy
    respond_to do |format|
      format.html { redirect_to board_comments_url, notice: 'Board comment was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_board_comment
      @board_comment = BoardComment.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def board_comment_params
      params.require(:board_comment).permit(:content, :user_id, :board_id)
    end
end
