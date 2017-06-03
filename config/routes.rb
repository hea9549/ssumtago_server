Rails.application.routes.draw do
  post 'users' => 'users#create'
  post 'sessions' => 'users#check'
end
