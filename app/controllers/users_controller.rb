require 'check_fb_token'

class UsersController < ApplicationController

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
      @fb_user = CheckFbToken.new(params[:access_token])
      render json: @fb_user.email
    elsif params[:joinType] == "email"
      @email_user = User.find_by_email(params[:email])
      
      render json: @email_user
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
