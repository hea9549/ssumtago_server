class SurveysController < ApplicationController
  before_action :set_survey, only: [:show, :update, :destroy]

  # GET /surveys
  def index
    logger.info "[LINE:#{__LINE__}] 모든 서베이를 불러옮 / 통신종료"
    @surveys = Survey.all
    render json: @surveys, status: :ok
  end

  # GET /surveys/1
  def show
    logger.info "[LINE:#{__LINE__}] _id: #{params[:id]} 의 서베이를 불러옮 / 통신종료"
    render json: @survey, status: :ok
  end

  # POST /surveys
  def create
    logger.info "[LINE:#{__LINE__}] 새로운 서베이를 만드는 중..."
    @survey = Survey.new(survey_params)
    logger.info "[LINE:#{__LINE__}] 새로운 서베이를 저장하는 중..."
    if @survey.save
      logger.info "[LINE:#{__LINE__}] 서베이 저장 완료 / 통신종료"
      render json: @survey, status: :created
    else
      logger.error "[LINE:#{__LINE__}] 저장 실패 / 통신종료"
      render json: @survey.errors, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /surveys/1
  def update
    logger.info "[LINE:#{__LINE__}] 서베이 업데이트 중..."
    if @survey.update(survey_params)
      logger.info "[LINE:#{__LINE__}] 서베이 수정 완료 / 통신종료"
      render json: @survey, status: :ok
    else
      logger.error "[LINE:#{__LINE__}] 서베이 수정 실패 / 통신종료"
      render json: @survey.errors, status: :unprocessable_entity
    end
  end

  # DELETE /surveys/1
  def destroy
    logger.info "[LINE:#{__LINE__}] 특정 서베이 삭제 완료 / 통신종료"
    @survey.destroy

    @success = {success:"썸 삭제 완료"}
    render json: @success, status: :ok
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_survey
      logger.info "[LINE:#{__LINE__}] 특정 서베이를 찾는 중..."
      @survey = Survey.find_by(surveyId:params[:surveyId])
    end

    # Only allow a trusted parameter "white list" through.
    def survey_params
      params.permit(
        :name,
        :answerCodes,
        :version,
        :surveyId,
        :desc,
        :isAvailable,
        :excludeCodes => [],
        :parameters => [
          :feature_num,
          :num_of_unit,
          :keep_prob,
          :learning_rate,
          :max_learning_point
        ],
        :models =>
          [
          :id,
          :accuracy,
          :train_data,
          :metaFileName,
          :checkPoint,
          :parameters =>
            [
            :featureNum,
            :numOfUnit,
            :keepProb,
            :learningRate,
            :maxLearningPoint
            ]
          ],
        :questions =>
          [
            :desc,
            :code,
            :imgCode,
            :answers =>
              [
                :desc,
                :img,
                :code,
                :name => []
              ],
            :name => []
          ]
      )
    end
end
