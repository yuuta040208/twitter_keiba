Rails.application.routes.draw do
  root 'races#index'

  resources :races, only: [:index, :show] do
    get :tweets
  end
  resources :users, only: [:index, :show]
  resources :bets, only: [:index, :show]

  namespace :admin do
    resources :races, only: [:index, :update]
  end
end
