class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception
  def loginCheck
    unless user_signed_in?
      redirect_to '/users/sign_in'
    end
  end

  def masterCheck
    unless current_user.isMaster == true || current_user.email == "guest@likelion.org"
      redirect_to '/projects'
    end
  end

  def messageAll
    @messages = Message.all
  end
end
