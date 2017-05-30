Rails.application.routes.draw do
  post 'users' => 'users#create'
  get 'sessions' => 'users#check'
end
