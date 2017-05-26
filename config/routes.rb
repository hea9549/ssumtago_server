Rails.application.routes.draw do
  get 'authn/checkLogin'

  mount_devise_token_auth_for 'User', at: 'user/login'
  post "/user/new" => "devise_token_auth/registrations#create"
  post "/user/login/normal" => "devise_token_auth/sessions#create"
  # get "/user/login/:provider" => redirect(301)
  # resources :users
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
