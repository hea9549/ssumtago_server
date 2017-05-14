Rails.application.routes.draw do
  resources :cards
  get 'cards/check/:id' => 'cards#check'

  get 'rooms/show'

  resources :boards
  get 'boards/index/:id' => 'boards#index'
  get 'boards/new/:id' => 'boards#new'
  get 'boards/edit/:id' => 'boards#edit'
  resources :board_comments

  get 'accounting/index'

  get 'home/index'

  # devise_for :users, :controllers => { :registrations => 'registrations' }

  devise_scope :user do
    get "/sign_in" => "devise/sessions#new" # custom path to login/sign_in
    get "/sign_up" => "devise/registrations#new", as: "new_user_registration" # custom path to sign_up/registration
  end

  devise_for :users, :skip => [:registrations]
    as :user do
    get 'users/edit' => 'devise/registrations#edit', :as => 'edit_user_registration'
    put 'users' => 'devise/registrations#update', :as => 'user_registration'
  end

  resources :teams
  get 'mypage/index'

  resources :lectures
  get 'lectures/check/:id' => 'lectures#check'
  get 'lectures/index/:id' => 'lectures#index'

  mount Ckeditor::Engine => '/ckeditor'
  get 'manage' => "manage#index"
  get 'manage/:id' => "manage#show"
  get 'manage/:id/new' => "manage#new"
  get 'manage/:id/edit' => "manage#edit"

  resources :comments
  get 'comments/new'
  get 'comments/destroy'

  get 'projects/like/:id' => 'projects#like'

  get 'projects/landing'
  get 'projects/index/:id' => 'projects#index'
  resources :projects


  get 'mailer/index'
  get 'mailer/sender'
  resources :rounds


  # root 'projects#landing'
  root 'home#index'

  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  mount ActionCable.server => '/cable'

end
