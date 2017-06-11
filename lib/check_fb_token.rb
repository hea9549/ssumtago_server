# 페이스북 토큰을 검증하는 클래스
class CheckFbToken

  # 초기화 메서드 (페이스북 oauth 토큰 필요)
  def initialize(oauth_access_token)
    @oauth_access_token = oauth_access_token
  end

  # 실제로 토큰값을 검증하는 메서드
  def verify
    graph = Koala::Facebook::API.new(@oauth_access_token)
    info = graph.get_object('me', fields:'email, verified, name')
    info_hash = {email: info["email"], valid: info["verified"], name: info["name"]}
    # email / valid 값이 담긴 해쉬를 return
    return info_hash
  end
end
