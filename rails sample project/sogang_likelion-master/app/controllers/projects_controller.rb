class ProjectsController < ApplicationController
  before_action :loginCheck
  before_action :messageAll
  before_action :set_project, only: [:show, :edit, :update, :destroy]

  # GET /projects
  # GET /projects.json
  def index
    @team = Team.find(params[:id])

    @projects = Project.order(updated_at: :desc).joins(:user).where(:users=>{team:params[:id]})

  end

  # GET /projects/1
  # GET /projects/1.json
  def show
    @comment = Comment.new
  end

  # GET /projects/new
  def new
    @project = Project.new
  end

  # GET /projects/1/edit
  def edit
  end

  # POST /projects
  # POST /projects.json
  def create
    @project = Project.new(project_params)

    respond_to do |format|
      if @project.save
        format.html { redirect_to @project, notice: '웹사이트 등록 완료!' }
        format.json { render :show, status: :created, location: @project }
      else
        format.html { render :new }
        format.json { render json: @project.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /projects/1
  # PATCH/PUT /projects/1.json
  def update
    respond_to do |format|
      if @project.update(project_params)
        format.html { redirect_to @project, notice: '웹사이트 업데이트 완료!' }
        format.json { render :show, status: :ok, location: @project }
      else
        format.html { render :edit }
        format.json { render json: @project.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /projects/1
  # DELETE /projects/1.json
  def destroy
    @project.destroy

    # if @project.likes.length > 0
    #   @project.likes.each do |l|
    #     l.destroy
    #   end
    # end
    #
    # if @project.comments.length > 0
    #   @project.comments.each do |c|
    #     c.destroy
    #   end
    # end

    respond_to do |format|
      format.html { redirect_to projects_url, notice: '웹사이트 삭제 완료!' }
      format.json { head :no_content }
    end
  end

  def like
    if current_user.likes.where(project_id: params[:id]).length == 1
      @like = current_user.likes.where(project_id: params[:id]).first
      @like.destroy
    else
      @like = Like.new
      @like.user_id = current_user.id
      @like.project_id = params[:id]
      @like.save
    end

    redirect_to :back

  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_project
      @project = Project.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def project_params
      params.require(:project).permit(:title, :link, :link, :content, :user_id, :img, :gitLink)
    end
end
