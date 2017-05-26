class AuthnController < ApplicationController
  before_action :authenticate_user!

  def checkLogin
    render json: current_user || {}
  end
  
end
