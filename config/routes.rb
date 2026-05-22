Rails.application.routes.draw do
  get "up" => "rails/health#show", as: :rails_health_check

  root "posts#index"

  devise_for :users

  resources :posts do
    resources :comments, only: [:index]
    resources :likes, only: [:index]
  end

  resources :pets, except: [:index]

  resources :comments
  resources :likes

  resources :walk_events
  resources :walk_participants, only: [:create, :update, :destroy]

  resources :user_friendships, only: [:index, :create, :update, :destroy]
  resources :pet_friendships, only: [:index, :create, :update, :destroy]

  resources :users, only: [:index]

  get ":username" => "users#show", as: :user
  get ":username/posts" => "users#posts", as: :user_posts
  get ":username/pets" => "users#pets", as: :user_pets
  get ":username/friends" => "users#friends", as: :user_friends
end
