require 'check_fb_token'

class UsersController < ApplicationController
  @@hmac_secret = ENV['HAMC_SECRET']

  def index
    @users = User.all
    render json: @users
  end

  def show
    @user = current_user
    render json: @user
  end

  def check
    if params[:joinType] == "facebook"
      @fb_user = CheckFbToken.new(params[:password])
      @is_valid = @fb_user.verify
      @token = JWT.encode @is_valid, @@hmac_secret, 'HS256'
      @response = {jwt: @token}
      render json: @response
    elsif params[:joinType] == "email"
      @user = User.find_by(email: params[:email])
      @is_valid = {email: @user["email"], valid: @user.authenticate(params[:password])? true: false}
      @token = JWT.encode @is_valid, @@hmac_secret, 'HS256'
      @response = {jwt: @token}
      render json: @response
    else
      @error_message = {error: "joinType 값을 넣어주세요! (facebook/email)"}
      render json: @error_message
    end
  end

  def create
    @user = User.new(user_params)
    if @user.save
      render json: @user, status: :created
    else
      render json: @user.errors, status: :unprocessable_entity
    end
  end

  private

    # def set_user
    #   @user = User.find(params[:todo_list_id])
    # end

    def user_params
      params.require(:user).permit(:email, :password, :name, :sex, :age, :joinType, :fcmToken, :createdTime, :updatedTime, :lastSurveyed, :ssums)
    end
end
