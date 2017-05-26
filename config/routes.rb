Rails.application.routes.draw do
  get 'authn/checkLogin'

  mount_devise_token_auth_for 'User', at: 'users'
  # resources :users
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
