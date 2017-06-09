require 'check_fb_token'

class UsersController < ApplicationController
  before_action :check_jwt, only:[:show]
  @@hmac_secret = ENV['HAMC_SECRET']

  def index
    @users = User.all
    render json: @users
  end

  def show
    render json: @decoded_token, status: :ok
  end

  def login
      begin @user = User.where(joinType: params[:user][:joinType]).find_by(email: params[:user][:email])
        if @user.authenticate(Digest::SHA1.hexdigest(params[:user][:password]))? true: false
          @info = {email: @user["email"], role:["user"], creator: "API server", expireTime: Time.now + 24.hours}
          @token = JWT.encode @info, @@hmac_secret, 'HS256'
          @success = {success:"로그인에 성공했습니다.", jwt: @token}
          render json: @success, status: :ok
        else
          @error = {msg: "비밀번호가 올바르지 않습니다.", code:"400", time:Time.now}
          render json: @error, status: :bad_request
        end
      rescue Mongoid::Errors::DocumentNotFound
        if params[:user][:joinType] == "facebook"
          @fb_user = CheckFbToken.new(params[:user][:password])
          begin @is_valid = @fb_user.verify
            @user = User.new(user_params)
            @user.password = Digest::SHA1.hexdigest(params[:user][:password])
            puts @user.save!
            if @user.save
              @info = {email: @user.email, role:["user"], creator: "API server", expireTime: Time.now + 24.hours}
              @token = JWT.encode @info, @@hmac_secret, 'HS256'
              @success = {success:"회원가입에 성공했습니다.", jwt: @token}
              render json: @success, status: :created
            else
              @error = {msg:"서버 에러로 저장이 실패했습니다.", code:"500", time:Time.now}
              render json: @error, status: :internal_server_error
            end
          rescue Koala::Facebook::AuthenticationError
            @error = {msg:"페이스북 토큰이 유효하지 않습니다.", code:"401", time:Time.now}
            render json: @error, status: :unauthorized
          end
        else
          @error = {msg: "존재하지 않는 이메일입니다.", code:"400", time:Time.now}
          render json: @error, status: :bad_request
        end
      end
  end

  def create
    # joinType이 email인지 확인
    if params[:user][:joinType] == "email"
      # 존재하는 회원인지 확인 후 존재하면 에러
      begin @user = User.find_by(email: params[:user][:email])
        @error = {msg: "이미 가입된 이메일입니다.", code:"400", time:Time.now}
        render json: @error, status: :bad_request
      # 존재하지 않으면 가입
      rescue Mongoid::Errors::DocumentNotFound
        @user = User.new(user_params)
        @user.password = Digest::SHA1.hexdigest(params[:user][:password])
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
      @error = {msg: "joinType 값을 넣어주세요! (email)", code:"400", time:Time.now}
      render json: @error, status: :bad_request
    end
  end

  def fcm_push
    @headers = {
      "Content-Type" => "application/json",
      "Authorization" => "key=AAAAqms91F8:APA91bGjBdzhydJBsXyJt-1KVPVwiODVugMMlmyqcH1PrNo35HZ0XUsQujcht7_DywzWrEkIFXirXkIbtiUS8pioQwtrNxXRaX_LmcmI3IVPOhpX655J-pfR5c8CH6D68ncbteOoDwn8"
    }
    @body = {
      "data" => {
        "score" => "5x1",
        "time" => "15:10"
      },
      "to" => "bk3RNwTe3H0:CI2k_HHwgIpoDKCIZvvDMExUdFQ3P1..."
    }
    @result = HTTParty.post(
      "https://fcm.googleapis.com/fcm/send",
      headers: @headers,
      body: @body.to_json
    )

    return @result
  end

  private

    def user_params
      params.require(:user).permit(:email, :password, :joinType, :name, :sex, :age, :fcmToken, :createdTime, :updatedTime, :lastSurveyed, :ssums)
    end

end
