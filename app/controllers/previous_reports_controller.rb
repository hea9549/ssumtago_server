class PreviousReportsController < ApplicationController
  before_action :check_jwt, only: [:create]
  before_action :set_previous_report, only: [:show, :update, :destroy]

  # GET /previous_reports
  def index
    @previous_reports = PreviousReport.all

    render json: @previous_reports
  end

  # GET /previous_reports/1
  def show
    render json: @previous_report
  end

  # POST /previous_reports
  def create
    logger.info "[LINE:#{__LINE__}] 해당 user 찾음, 설문지 저장 중..."
    @previous_report = PreviousReport.new
    @previous_report.survey_id2 = params[:surveyId2]
    @previous_report.request_time = DateTime.now
    @previous_report.user_id = @user.id
    params[:data].each do |data|
      ssumji = Ssumji.new
      ssumji.questionCode = data[:questionCode]
      ssumji.answerCode = data[:answerCode]
      @previous_report.data << ssumji
    end
    @user.surveyed_yn = true
    @user.save

    if @previous_report.save
      logger.info "[LINE:#{__LINE__}] user에 설문지 저장완료 / 통신종료"
      render json: @previous_report, status: :created
    else
      logger.info "[LINE:#{__LINE__}] 서버에러로 저장 실패 / 통신종료"
      @error = {msg:"서버 에러로 설문지 저장에 실패했습니다.", code:"500", time:Time.now}
      render json: @error, status: :internal_server_error
    end
  end

  # PATCH/PUT /previous_reports/1
  def update
    if @previous_report.update(previous_report_params)
      render json: @previous_report
    else
      render json: @previous_report.errors, status: :unprocessable_entity
    end
  end

  # DELETE /previous_reports/1
  def destroy
    @previous_report.destroy
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_previous_report
      @previous_report = PreviousReport.find(params[:id])
    end

    # Only allow a trusted parameter "white list" through.
    def previous_report_params
      params.fetch(:previous_report, {})
    end
end
