Rails.application.routes.draw do
  root "posts#index"

  resources :users, only: [:show]

  resources :posts
  resources :comments, only: [:create, :edit, :update, :destroy]
  resources :likes, only: [:create, :destroy]

  resources :pets, except: [:index]

  resources :walk_events
  resources :walk_participants, only: [:create, :update, :destroy]

  resources :user_friendships, only: [:index, :create, :update, :destroy]
  resources :pet_friendships, only: [:index, :create, :update, :destroy]

  get "up" => "rails/health#show", as: :rails_health_check
end
