# 사용자와 관련된 요청을 처리하는 컨트롤러

require 'check_fb_token'
logger = Logger.new Rails.root.join('log/development.log')
logger.formatter = Logger::Formatter.new


class UsersController < ApplicationController
  before_action :check_jwt, only:[:show, :update, :delete, :fcm_update]
  @@hmac_secret = ENV['HAMC_SECRET']

  # [POST] /sessions => 로그인 요청을 처리하는 메서드
  def login
    logger.info "[LINE:#{__LINE__}] joinType값 확인 중 ..."
    # 페이스북 로그인
    if params[:joinType] == "facebook"
      logger.info "[LINE:#{__LINE__}] joinType값 facebook, 페이스북 토큰값 확인 중..."
      @fb_user = CheckFbToken.new(params[:password])
      # 페이스북 토큰이 맞는지 인증
      begin @fb_info = @fb_user.verify
        logger.info "[LINE:#{__LINE__}] 페이스북 토큰값 확인 완료, 가입 여부 확인 중..."
        @user = User.where(joinType: "facebook").find_or_initialize_by(email:@fb_info[:email])
        # 페이스북으로 이미 가입한 회원일때
        if @user.persisted?
          logger.info "[LINE:#{__LINE__}] 기존 회원 확인, 로그인 성공 / 통신종료"
          # 페이스북은 매번 토큰 값이 달라지기 때문에
          # 따로 authenticate을 할 필요없이 토큰 자체가 valid 하면 바로 로그인
          # if @user.authenticate(Digest::SHA1.hexdigest(params[:password]))? true: false
            @info = {email: @user["email"], role:["user"], creator: "API server", expireTime: Time.now + 24.hours}
            @token = JWT.encode @info, @@hmac_secret, 'HS256'
            @userInfo = @user.as_json(:except => [:password_digest,:created_at, :updated_at])
            @userInfo["jwt"] = @token
            render json: @userInfo, status: :ok
            # @success = {success:"로그인에 성공했습니다.", jwt: @token}
            # render json: @success, status: :ok
          # else
          #   @error = {msg: "비밀번호가 올바르지 않습니다.", code:"400", time:Time.now}
          #   render json: @error, status: :bad_request
          # end
        # 페이스북 신규 회원일때
        else
          logger.info "[LINE:#{__LINE__}] 신규 회원 확인, 회원가입 진행 중..."
          @user.password = Digest::SHA1.hexdigest(params[:password])
          @user.joinType = params[:joinType]
          @user.name = @fb_info[:name]
          @user.sex = params[:sex]
          @user.age = params[:age]
          if @user.save
            logger.info "[LINE:#{__LINE__}] 신규 회원 가입 성공 / 통신종료"
            @info = {email: @user.email, role:["user"], creator: "API server", expireTime: Time.now + 24.hours}
            @token = JWT.encode @info, @@hmac_secret, 'HS256'
            @userInfo = @user.as_json(:except => [:password_digest,:created_at, :updated_at])
            @userInfo["jwt"] = @token
            render json: @userInfo, status: :created
            # @success = {success:"회원가입에 성공했습니다.", jwt: @token, userInfo: @userInfo}
            # render json: @success, status: :created
          else
            logger.error "[LINE:#{__LINE__}] 서버 에러로 회원가입 실패 / 통신종료"
            @error = {msg:"서버 에러로 저장이 실패했습니다.", code:"500", time:Time.now}
            render json: @error, status: :internal_server_error
          end
        end
      #페이스북 토큰이 잘못된 경우
      rescue Koala::Facebook::AuthenticationError
        logger.error "[LINE:#{__LINE__}] 페이스북 토큰값 인증 실패 / 통신종료"
        @error = {msg:"페이스북 토큰이 유효하지 않습니다.", code:"401", time:Time.now}
        render json: @error, status: :unauthorized
      end
    # 이메일 로그인
    elsif params[:joinType] == "email"
      logger.info "[LINE:#{__LINE__}] joinType값 email,  가입 여부 확인 중..."
      # 이메일이 가입되어 있는지 아닌지 확인
      begin @user = User.where(joinType: "email").find_by(email: params[:email])
        logger.info "[LINE:#{__LINE__}] 기존 회원 확인, 비밀번호 확인 중..."
        if @user.authenticate(Digest::SHA1.hexdigest(params[:password]))? true: false
          logger.info "[LINE:#{__LINE__}] 비밀번호 인증성공, 로그인 성공 / 통신종료"
          @info = {email: @user["email"], role:["user"], creator: "API server", expireTime: Time.now + 24.hours}
          @token = JWT.encode @info, @@hmac_secret, 'HS256'
          @userInfo = @user.as_json(:except => [:password_digest,:created_at, :updated_at])
          @userInfo["jwt"] = @token
          render json: @userInfo, status: :ok
          # @success = {success:"로그인에 성공했습니다.", jwt: @token}
          # render json: @success, status: :ok
        else
          logger.error "[LINE:#{__LINE__}] 비밀번호 인증실패 / 통신종료"
          @error = {msg: "비밀번호가 올바르지 않습니다.", code:"400", time:Time.now}
          render json: @error, status: :bad_request
        end
      # 가입된 이메일이 없다면 에러
      rescue Mongoid::Errors::DocumentNotFound
        logger.error "[LINE:#{__LINE__}] 존재하지 않는 이메일 / 통신종료"
        @error = {msg: "존재하지 않는 이메일입니다.", code:"400", time:Time.now}
        render json: @error, status: :bad_request
      end
    # joinType 값이 올바르지 않으면 에러
    else
      logger.error "[LINE:#{__LINE__}] joinType값이 없음 / 통신종료"
      @error = {msg: "joinType 값을 넣어주세요! (email/facebook)", code:"400", time:Time.now}
      render json: @error, status: :bad_request
    end
  end

  # [POST] /users => 이메일 회원가입을 처리하는 메서드
  def create
    logger.info "[LINE:#{__LINE__}] joinType값 확인 중 ..."
    # joinType이 email인지 확인
    if params[:joinType] == "email"
      logger.info "[LINE:#{__LINE__}] joinType값 email 확인, 이메일 중복 확인 중..."
      # 이메일 중복인지 확인 후 존재하면 에러
      begin @user = User.find_by(email: params[:email])
        logger.error "[LINE:#{__LINE__}] email값 중복 / 통신종료"
        @error = {msg: "이미 가입된 이메일입니다.", code:"400", time:Time.now}
        render json: @error, status: :bad_request
      # 존재하지 않으면 가입
      rescue Mongoid::Errors::DocumentNotFound
        logger.info "[LINE:#{__LINE__}] 이메일 중복 체크 완료, 회원가입 중..."
        @user = User.new(user_params)
        # 비밀번호 해싱
        @user.password = Digest::SHA1.hexdigest(params[:password])
        if @user.save
          logger.info "[LINE:#{__LINE__}] 회원가입 저장 완료 / 통신종료"
          @info = {email: @user.email, role:["user"], creator: "API server", expireTime: Time.now + 24.hours}
          @token = JWT.encode @info, @@hmac_secret, 'HS256'
          # @success = {success:"회원가입에 성공했습니다.", jwt: @token, userInfo: @userInfo}
          @userInfo = @user.as_json(:except => [:password_digest,:created_at, :updated_at])
          @userInfo["jwt"] = @token
          render json: @userInfo, status: :created
        else
          logger.error "[LINE:#{__LINE__}] 서버에러로 회원가입 저장 실패 / 통신종료"
          @error = {msg:"서버 에러로 저장이 실패했습니다.", code:"500", time:Time.now}
          render json: @error, status: :internal_server_error
        end
      end
    # joinType이 email이 아니라면 에러
    else
      logger.error "[LINE:#{__LINE__}] joinType값 오류 / 통신종료"
      @error = {msg: "올바른 joinType 값을 넣어주세요! (email)", code:"400", time:Time.now}
      render json: @error, status: :bad_request
    end
  end

  # [GET] /users/:userId => 유저 조회하는 메서드
  def show
    logger.info "[LINE:#{__LINE__}] jwt에 해당하는 user 정보 리턴완료 / 통신종료"
    @userInfo = @user.as_json(:except => [:password_digest,:created_at, :updated_at])
    render json: @userInfo, status: :ok
  end

  # [PATCH] /users/:userId => 유저를 수정하는 멧서드
  def update
    logger.info "[LINE:#{__LINE__}] 유저 확인, 유저 데이터 수정 중..."
    if @user.update(user_params)
      if params[:password]
        @user.password = Digest::SHA1.hexdigest(params[:password])
        @user.save
      end
      logger.info "[LINE:#{__LINE__}] 유저 수정 완료 / 통신종료"
      @userInfo = @user.as_json(:except => [:password_digest,:created_at, :updated_at])
      render json: @userInfo, status: :created
    else
      logger.error "[LINE:#{__LINE__}] 서버에러로 저장 실패 / 통신종료"
      @error = {msg: "서버에러로 유저 정보 수정에 실패 했습니다.", code:"500", time:Time.now}
      render json: @error, status: :internal_server_error
    end
  end

  # [DELETE] /users/:userId => 유저를 삭제하는 메서드
  def delete
    logger.info "[LINE:#{__LINE__}] 유저를 찾음, 삭제 완료 / 통신종료"
    @user.destroy
    @success = {success:"유저 삭제 완료"}
    render json: @success, status: :created
  end

  # [PATCH] /users => 유저 fcm 업데이트하는 메서드
  def fcm_update
    logger.info "[LINE:#{__LINE__}] jwt 값 확인, 파라미터에 fcmToken 여부 확인 중..."
    # 파라미터 fcmToken 값 여부 확인
    if params[:fcmToken]
      logger.info "[LINE:#{__LINE__}] fcmToken 확인, 해당 user의 fcmToken 수정 중..."
      @user.fcmToken = params[:fcmToken]
      if @user.save
        logger.info "[LINE:#{__LINE__}] user의 fcmToken 업데이트 완료 / 통신 종료"
        @success = {success:"#{@user.name}님의 fcmToken 업데이트를 완료했습니다."}
        render json: @success, status: :ok
      else
        logger.error "[LINE:#{__LINE__}] 서버 에러로 업데이트 실패 / 통신 종료"
        @error = {msg:"서버 에러로 저장이 실패했습니다.", code:"500", time:Time.now}
        render json: @error, status: :internal_server_error
      end
    else
      logger.error "[LINE:#{__LINE__}] 파라미터에 fcmToken 없음 / 통신 종료"
      @error = {msg: "Body에 fcmToken 값을 넣어주세요!", code:"400", time:Time.now}
      render json: @error, status: :bad_request
    end
  end

  private
    # User 컨트롤러 공용메서드를 적는 부분

    # 명시된 key값으로 날라오는 parameter들만 받는 메서드 (white list)
    def user_params
      params.permit(:email, :password, :joinType, :name, :sex, :age, :fcmToken)
      # params.require(:user).permit(:email, :password, :joinType, :name, :sex, :age, :fcmToken)
    end

end
