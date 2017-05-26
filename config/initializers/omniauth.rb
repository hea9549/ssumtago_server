Rails.application.config.middleware.use OmniAuth::Builder do
  provider :facebook, "1341830752573993", "e1db281bb53665afab874a9c06693ada"
  # provider :kakao, ENV['KAKAO_CLIENT_ID']
end
