Rails.application.routes.draw do

  # Users Controller 사용자 관련 Route
  ## 이메일 회원가입
  post 'users' => 'users#create'
  ## 유저 조회
  get 'users' => 'users#show'
  ## 유저 업데이트
  patch 'users' => 'users#update'
  ## 유저 삭제
  delete 'users' => 'users#delete'
  ## 로그인
  post 'sessions' => 'users#login'
  ## 유저 fcm업데이트
  # patch 'users/:userId' =>'users#fcm_update'

  # Surveys Controller 설문내용 관련 Route
  get 'surveys' => 'surveys#index'
  get 'surveys/:surveyId' => 'surveys#show'
  post 'surveys' => 'surveys#create'
  patch 'surveys/:surveyId' => 'surveys#update'
  delete 'surveys/:surveyId' => 'surveys#delete'


  # Ssums Controller 썸 관련 Route
  ## 썸 Read
  # get 'ssums/:ssumId' => 'ssums#read_ssum'
  # get 'ssums' => 'ssums#read_ssum'
  ## 썸 Create
  # post 'ssums' => 'ssums#create_ssum'
  ## 썸 Update
  # patch 'ssums/:ssumId' => 'ssums#update_ssum'
  # patch 'ssums' => 'ssums#update_ssum'
  ## 썸 Delete
  # delete 'ssums/:ssumId' => 'ssums#delete_ssum'
  # delete 'ssums' => 'ssums#delete_ssum'


  # Reports Controller 설문지 관련 Route
  ## 설문지 요청
  # get 'ssums/:ssumId/predictReports/:reportId' => 'reports#read_sruvey'
  get 'predictReports/:reportId' => 'reports#read_sruvey'
  ## 설문지 만들기
  # post 'ssums/:ssumId/predictReports' => 'reports#create_survey'
  post 'predictReports' => 'reports#create_survey'
  ## 설문지 업데이트
  # patch 'ssums/:ssumId/predictReports/:reportId' => 'reports#update_survey'
  patch 'predictReports/:reportId' => 'reports#update_survey'
  ## 설문지 삭제
  # delete 'ssums/:ssumId/predictReports/:reportId' => 'reports#delete_survey'
  delete 'predictReports/:reportId' => 'reports#delete_survey'

  ## 결과값 요청
  post 'predictResults/:reportId' => 'reports#result'
end
