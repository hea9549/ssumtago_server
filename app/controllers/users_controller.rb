require 'check_fb_token'

class UsersController < ApplicationController
  @@hmac_secret = ENV['HAMC_SECRET']

  def index
    @users = User.all
    render json: @users
  end

  def show
    if request.headers["jwt"]
      @jwt = request.headers["jwt"]
      begin @info = token_check(@jwt)[0]
        if Time.now <= Time.parse(@info["expireTime"])
          @user = User.find_by(email: @info["email"])
          render json: @user
        else
          @error = {error: "Token이 만기됐습니다!"}
          render json: @error
        end
      rescue JWT::IncorrectAlgorithm
        @error = {error: "올바른 Token 값을 넣어주세요!"}
        render json: @error
      end
    else
      @error = {error: "Header에 Token 값을 넣어주세요!"}
      render json: @error
    end
  end

  def login
      begin @user = User.where(joinType: params[:user][:joinType]).find_by(email: params[:user][:email])
        if @user.authenticate(params[:user][:password])? true: false
          @info = {email: @user["email"], role:["user"], creator: "API server", expireTime: Time.now + 24.hours}
          @token = JWT.encode @info, @@hmac_secret, 'HS256'
          @success = {success:"로그인에 성공했습니다.", jwt: @token}
          render json: @success, status: :created
        else
          @error = {error: "비밀번호가 올바르지 않습니다."}
          render json: @error, status: :unprocessable_entity
        end
      rescue Mongoid::Errors::DocumentNotFound
        @error = {error: "존재하지 않는 이메일입니다."}
        render json: @error, status: :unprocessable_entity
      end
  end

  def create
    if params[:user][:joinType] == "facebook"
      @fb_user = CheckFbToken.new(params[:user][:password])
      @is_valid = @fb_user.verify
      @user = User.new(user_params)
      if @is_valid
        if @user.save
          @info = {email: @user["email"], role:["user"], creator: "API server", expireTime: Time.now + 24.hours}
          @token = JWT.encode @info, @@hmac_secret, 'HS256'
          @success = {success:"회원가입에 성공했습니다.", jwt: @token}
          render json: @success, status: :created
        else
          @error = {error:"저장이 실패했습니다."}
          render json: @error, status: :unprocessable_entity
        end
      else
        @error = {error:"페이스북 토큰이 유효하지 않습니다."}
        render json: @error, status: :unprocessable_entity
      end

    elsif params[:user][:joinType] == "email"
      @user = User.new(user_params)
      if @user.save
        @info = {email: @user["email"], role:["user"], creator: "API server", expireTime: Time.now + 24.hours}
        @token = JWT.encode @info, @@hmac_secret, 'HS256'
        @success = {success:"회원가입에 성공했습니다.", jwt: @token}
        render json: @success, status: :created
      else
        @error = {error:"저장이 실패했습니다."}
        render json: @error, status: :unprocessable_entity
      end
    else
      @error = {error: "joinType 값을 넣어주세요! (facebook/email)"}
      render json: @error, status: :unprocessable_entity
    end
  end

  private

    def user_params
      params.require(:user).permit(:email, :password, :joinType, :name, :sex, :age, :fcmToken, :createdTime, :updatedTime, :lastSurveyed, :ssums)
    end

    def token_check request_token
      decoded_token = JWT.decode request_token, @@hmac_secret, true, { :algorithm => 'HS256' }
      return decoded_token
    end

end
