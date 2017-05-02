require 'mechanize'

class ManageController < ApplicationController
  before_action :masterCheck
  before_action :messageAll

  def index
    @users = User.all
  end

  def show
    @user = User.find(params[:id])
  end

  def new
    @teams = Team.all
    @user = User.find(params[:id])
    @user.team = @teams.last
    @user.save

    redirect_to :back
  end

  def edit
    @user = User.find(params[:id])
    if @user.team.name == "그리핀도르"
      @user.team = Team.find_by(name:"슬리데린")
    elsif @user.team.name == "슬리데린"
      @user.team = Team.find_by(name:"운영진")
    else
      @user.team = Team.find_by(name:"그리핀도르")
    end

    @user.save

    redirect_to :back
  end
end
