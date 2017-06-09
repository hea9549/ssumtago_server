Rails.application.routes.draw do
  post 'users' => 'users#create'
  post 'sessions' => 'users#login'
  post 'check' => 'users#show'
  post 'fcm' => 'users#fcm_push'

  post 'predictReports' => 'surveys#input_survey'
  post 'predictResults' => 'surveys#result'
end
