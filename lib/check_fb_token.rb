require 'httparty'

class CheckFbToken

  def initialize(oauth_access_token)
    @oauth_access_token = oauth_access_token
  end

  def email
    graph = Koala::Facebook::API.new(@oauth_access_token)
    graph.get_object('me', fields:'email, verified')
  end
end
