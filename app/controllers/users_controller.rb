# 사용자와 관련된 요청을 처리하는 컨트롤러

require 'check_fb_token'

class UsersController < ApplicationController
  before_action :check_jwt, only:[:show]
  @@hmac_secret = ENV['HAMC_SECRET']

  # [POST] /sessions => 로그인 요청을 처리하는 메서드
  def login
    # 페이스북 로그인
    if params[:joinType] == "facebook"
      @fb_user = CheckFbToken.new(params[:password])
      # 페이스북 토큰이 맞는지 인증
      begin @fb_email = @fb_user.verify[:email]
        @user = User.where(joinType: "facebook").find_or_initialize_by(email:@fb_email)
        # 페이스북으로 이미 가입한 회원일때
        if @user.persisted?
          # 페이스북은 매번 토큰 값이 달라지기 때문에
          # 따로 authenticate을 할 필요없이 토큰 자체가 valid 하면 바로 로그인
          # if @user.authenticate(Digest::SHA1.hexdigest(params[:password]))? true: false
            @info = {email: @user["email"], role:["user"], creator: "API server", expireTime: Time.now + 24.hours}
            @token = JWT.encode @info, @@hmac_secret, 'HS256'
            @success = {success:"로그인에 성공했습니다.", jwt: @token}
            render json: @success, status: :ok
          # else
          #   @error = {msg: "비밀번호가 올바르지 않습니다.", code:"400", time:Time.now}
          #   render json: @error, status: :bad_request
          # end
        # 페이스북 신규 회원일때
        else
          @user.password = Digest::SHA1.hexdigest(params[:password])
          @user.joinType = params[:joinType]
          @user.name = params[:name]
          @user.sex = params[:sex]
          @user.age = params[:age]
          if @user.save
            @info = {email: @user.email, role:["user"], creator: "API server", expireTime: Time.now + 24.hours}
            @token = JWT.encode @info, @@hmac_secret, 'HS256'
            @success = {success:"회원가입에 성공했습니다.", jwt: @token}
            render json: @success, status: :created
          else
            @error = {msg:"서버 에러로 저장이 실패했습니다.", code:"500", time:Time.now}
            render json: @error, status: :internal_server_error
          end
        end
      #페이스북 토큰이 잘못된 경우
      rescue Koala::Facebook::AuthenticationError
        @error = {msg:"페이스북 토큰이 유효하지 않습니다.", code:"401", time:Time.now}
        render json: @error, status: :unauthorized
      end
    # 이메일 로그인
    elsif params[:joinType] == "email"
      # 이메일이 가입되어 있는지 아닌지 확인
      begin @user = User.where(joinType: "email").find_by(email: params[:email])
        if @user.authenticate(Digest::SHA1.hexdigest(params[:password]))? true: false
          @info = {email: @user["email"], role:["user"], creator: "API server", expireTime: Time.now + 24.hours}
          @token = JWT.encode @info, @@hmac_secret, 'HS256'
          @success = {success:"로그인에 성공했습니다.", jwt: @token}
          render json: @success, status: :ok
        else
          @error = {msg: "비밀번호가 올바르지 않습니다.", code:"400", time:Time.now}
          render json: @error, status: :bad_request
        end
      # 가입된 이메일이 없다면 에러
      rescue Mongoid::Errors::DocumentNotFound
        @error = {msg: "존재하지 않는 이메일입니다.", code:"400", time:Time.now}
        render json: @error, status: :bad_request
      end
    # joinType 값이 올바르지 않으면 에러
    else
      @error = {msg: "joinType 값을 넣어주세요! (email/facebook)", code:"400", time:Time.now}
      render json: @error, status: :bad_request
    end



    # 이전 코드 2017.06.09
    # 곧 삭제 예정
      # begin @user = User.where(joinType: params[:joinType]).find_by(email: params[:email])
      #   if @user.authenticate(Digest::SHA1.hexdigest(params[:password]))? true: false
      #     @info = {email: @user["email"], role:["user"], creator: "API server", expireTime: Time.now + 24.hours}
      #     @token = JWT.encode @info, @@hmac_secret, 'HS256'
      #     @success = {success:"로그인에 성공했습니다.", jwt: @token}
      #     render json: @success, status: :ok
      #   else
      #     @error = {msg: "비밀번호가 올바르지 않습니다.", code:"400", time:Time.now}
      #     render json: @error, status: :bad_request
      #   end
      # rescue Mongoid::Errors::DocumentNotFound
      #   if params[:joinType] == "facebook"
      #     @fb_user = CheckFbToken.new(params[:password])
      #     begin @is_valid = @fb_user.verify
      #       @user = User.new(user_params)
      #       @user.password = Digest::SHA1.hexdigest(params[:password])
      #       if @user.save
      #         @info = {email: @user.email, role:["user"], creator: "API server", expireTime: Time.now + 24.hours}
      #         @token = JWT.encode @info, @@hmac_secret, 'HS256'
      #         @success = {success:"회원가입에 성공했습니다.", jwt: @token}
      #         render json: @success, status: :created
      #       else
      #         @error = {msg:"서버 에러로 저장이 실패했습니다.", code:"500", time:Time.now}
      #         render json: @error, status: :internal_server_error
      #       end
      #     rescue Koala::Facebook::AuthenticationError
      #       @error = {msg:"페이스북 토큰이 유효하지 않습니다.", code:"401", time:Time.now}
      #       render json: @error, status: :unauthorized
      #     end
      #   else
      #     @error = {msg: "존재하지 않는 이메일입니다.", code:"400", time:Time.now}
      #     render json: @error, status: :bad_request
      #   end
      # end
  end

  # [POST] /users => 이메일 회원가입을 처리하는 메서드
  def create
    # joinType이 email인지 확인
    if params[:joinType] == "email"
      # 존재하는 회원인지 확인 후 존재하면 에러
      begin @user = User.find_by(email: params[:email])
        @error = {msg: "이미 가입된 이메일입니다.", code:"400", time:Time.now}
        render json: @error, status: :bad_request
      # 존재하지 않으면 가입
      rescue Mongoid::Errors::DocumentNotFound
        @user = User.new(user_params)
        # 비밀번호 해싱
        @user.password = Digest::SHA1.hexdigest(params[:password])
        if @user.save
          @info = {email: @user.email, role:["user"], creator: "API server", expireTime: Time.now + 24.hours}
          @token = JWT.encode @info, @@hmac_secret, 'HS256'
          @success = {success:"회원가입에 성공했습니다.", jwt: @token}
          render json: @success, status: :created
        else
          @error = {msg:"서버 에러로 저장이 실패했습니다.", code:"500", time:Time.now}
          render json: @error, status: :internal_server_error
        end
      end
    # joinType이 email이 아니라면 에러
    else
      @error = {msg: "올바른 joinType 값을 넣어주세요! (email)", code:"400", time:Time.now}
      render json: @error, status: :bad_request
    end
  end

  # [POST] /check => jwt 값을 확인하는 메서드
  def show
    render json: @decoded_token, status: :ok
  end

  private
    # User 컨트롤러 공용메서드를 적는 부분

    # 명시된 key값으로 날라오는 parameter들만 받는 메서드 (white list)
    def user_params
      params.permit(:email, :password, :joinType, :name, :sex, :age, :fcmToken, :createdTime, :updatedTime, :lastSurveyed, :ssums)
    end

end
