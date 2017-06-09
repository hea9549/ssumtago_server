Rails.application.routes.draw do
  post 'users' => 'users#create'
  post 'sessions' => 'users#login'
  post 'check' => 'users#show'
  post 'fcm' => 'users#fcm_push'

  post 'predictReports' => 'reports#input_survey'
  post 'predictResults' => 'reports#result'
end
