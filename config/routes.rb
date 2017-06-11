Rails.application.routes.draw do

  # User Controller 사용자 관련 Route
  ## 이메일 회원가입
  post 'users' => 'users#create'
  ## 로그인
  post 'sessions' => 'users#login'

  ## JWT 테스트용 url
  post 'check' => 'users#show'

  # Reports Controller 설문지 관련 Route
  ## 설문지 요청
  post 'predictReports' => 'reports#input_survey'
  ## 결과값 요청
  post 'predictResults' => 'reports#result'
  post 'fcm' => 'reports#fcm_push'
end
