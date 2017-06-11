Rails.application.routes.draw do

  # User Controller 사용자 관련 Route
  ## 이메일 회원가입
  post 'users' => 'users#create'
  ## 유저 조회
  get 'users' => 'users#show'
  ## 수정된 fcm 토큰
  patch 'users' =>'users#fcm_refresh'
  ## 로그인
  post 'sessions' => 'users#login'

  # Reports Controller 설문지 관련 Route
  ## 설문지 요청
  post 'predictReports' => 'reports#input_survey'
  ## 결과값 요청
  post 'predictResults' => 'reports#result'
  post 'fcm' => 'reports#fcm_push'
end
