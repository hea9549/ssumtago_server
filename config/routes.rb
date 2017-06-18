Rails.application.routes.draw do

  # User Controller 사용자 관련 Route
  ## 이메일 회원가입
  post 'users' => 'users#create'
  ## 유저 조회
  get 'users' => 'users#show'
  ## 수정된 fcm 토큰
  patch 'users' =>'users#fcm_update'
  ## 로그인
  post 'sessions' => 'users#login'

  # Reports Controller 설문지 관련 Route
  ## 설문지 요청
  get 'predictReports/:reportId' => 'reports#read_sruvey'
  post 'predictReports' => 'reports#create_survey'
  patch 'predictReports' => 'reports#update_survey'
  delete 'predictReports/:reportId' => 'reports#delete_survey'


  ## 결과값 요청
  post 'predictResults' => 'reports#result'
end
