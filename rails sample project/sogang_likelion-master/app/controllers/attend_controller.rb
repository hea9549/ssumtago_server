class AttendController < ApplicationController
  before_action :messageAll

  def check
  end

  def new
    @rounds = Round.new
  end

  def index
  end

  def result
  end
end
