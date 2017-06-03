class CheckFbToken

  def initialize(oauth_access_token)
    @oauth_access_token = oauth_access_token
  end

  def verify
    graph = Koala::Facebook::API.new(@oauth_access_token)
    info = graph.get_object('me', fields:'email, verified')
    info_hash = {email: info["email"], valid: info["verified"]}
    return info_hash
  end
end
