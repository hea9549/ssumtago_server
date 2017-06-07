Rails.application.routes.draw do
  post 'users' => 'users#create'
  post 'sessions' => 'users#login'
  post 'check' => 'users#show'
  post 'fcm' => 'users#fcm_push'

  post 'send_survey' => 'surveys#input_survey'
  post 'get_result' => 'surveys#result'
end
