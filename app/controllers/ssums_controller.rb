class SsumsController < ApplicationController
  before_action :check_jwt, only: [:create_ssum, :read_ssum, :update_ssum, :delete_ssum]

  # [POST] /ssums => 새로운 썸을 만드는 메서드 (check_jwt 메서드가 선행됨)
  def create_ssum
    logger.info "[LINE:#{__LINE__}] 해당 user 찾음, 썸 만들기 시작..."
    ssum = Ssum.new
    ssum.name = params[:name]
    ssum.age = params[:age]
    ssum.sex = params[:sex]
    @user.ssums << ssum
    if @user.save
      logger.info "[LINE:#{__LINE__}] 썸 저장완료, 통신종료"
      render json: ssum, status: :ok
      # @success = {success:"썸 저장에 성공했습니다."}
      # render json: @success, status: :ok
    else
      logger.error "[LINE:#{__LINE__}] 서버 에러로 썸 저장 실패 / 통신종료"
      @error = {msg:"서버 에러로 썸 저장에 실패했습니다.", code:"500", time:Time.now}
      render json: @error, status: :internal_server_error
    end
  end

  # [GET] /ssums/:ssumId => 해당 썸을 불러오는 메서드 (check_jwt 메서드가 선행됨)
  def read_ssum
    logger.info "[LINE:#{__LINE__}] 해당 user 찾음, 해당 id의 썸이 있는지 찾는 중..."
    begin @ssum = @user.ssums.find_by(id:params[:ssumId])
      logger.info "[LINE:#{__LINE__}] 썸 확인, 썸 데이터 응답 완료 / 통신종료"

      render json: @ssum, status: :ok
      # @success = {success:"썸 데이터 응답 완료", ssum: @ssum}
      # render json: @success, status: :ok

    # 썸을 찾을 수 없을 때
    rescue Mongoid::Errors::DocumentNotFound
      logger.error "[LINE:#{__LINE__}] user에 해당 ssumId의 설문지를 찾을 수 없음 / 통신종료"
      @error = {msg:"user에 해당 ssumId의 썸을 찾을 수 없습니다.", code:"500", time:Time.now}
      render json: @error, status: :internal_server_error
    end
  end

  # [PATCH] /ssums/:ssumId => 썸 내용 수정하는 메서드 (check_jwt 메서드가 선행됨)
  def update_ssum
    logger.info "[LINE:#{__LINE__}] 해당 user 찾음, 해당 id의 썸이 있는지 찾는 중..."
    begin @ssum = @user.ssums.find_by(id:params[:ssumId])
      logger.info "[LINE:#{__LINE__}] 썸 확인, 썸 업데이트 중..."
      @ssum.name = params[:name]
      @ssum.age = params[:age]
      @ssum.sex = params[:sex]
      if @ssum.save
        logger.info "[LINE:#{__LINE__}] 썸 수정완료 / 통신종료"
        render json: @ssum, status: :ok
        # @success = {success:"썸 수정에 성공했습니다."}
        # render json: @success, status: :ok
      else
        logger.error "[LINE:#{__LINE__}] 서버 에러로 썸 저장 실패 / 통신종료"
        @error = {msg:"서버 에러로 썸 저장에 실패했습니다.", code:"500", time:Time.now}
        render json: @error, status: :internal_server_error
      end

    # 썸을 찾을 수 없을 때
    rescue Mongoid::Errors::DocumentNotFound
      logger.error "[LINE:#{__LINE__}] user에 해당 ssumId의 설문지를 찾을 수 없음 / 통신종료"
      @error = {msg:"user에 해당 ssumId의 썸을 찾을 수 없습니다.", code:"500", time:Time.now}
      render json: @error, status: :internal_server_error
    end

  end

  # [DELETE] /ssums/:ssumId => 썸을 삭제하는 메서드 (check_jwt 메서드가 선행됨)
  def delete_ssum
    logger.info "[LINE:#{__LINE__}] 해당 user 찾음, 해당 id의 썸이 있는지 찾는 중..."
    begin @ssum = @user.ssums.find_by(id:params[:ssumId])
      logger.info "[LINE:#{__LINE__}] 썸 확인, 썸 삭제 완료 / 통신종료"
      @ssum.destroy

      @success = {success:"썸 삭제 완료"}
      render json: @success, status: :ok

    # 썸을 찾을 수 없을 때
    rescue Mongoid::Errors::DocumentNotFound
      logger.error "[LINE:#{__LINE__}] user에 해당 ssumId의 설문지를 찾을 수 없음 / 통신종료"
      @error = {msg:"user에 해당 ssumId의 썸을 찾을 수 없습니다.", code:"500", time:Time.now}
      render json: @error, status: :internal_server_error
    end
  end


  private
    # Ssums 컨트롤러 공용메서드를 적는 부분

    # 명시된 key값으로 날라오는 parameter들만 받는 메서드 (white list)
    def ssum_params
      params.permit(:name, :age, :sex)
    end
end
