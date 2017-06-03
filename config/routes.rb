Rails.application.routes.draw do
  post 'users' => 'users#create'
  post 'sessions' => 'users#login'
  post 'check' => 'users#show'
end
