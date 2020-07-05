Rails.application.routes.draw do
  root 'races#index'

  resources :races, only: [:index, :show] do
    get :tweets
    get :bets
    get :recommendations
    get :odds
  end

  resources :users, only: [:index, :show]
  resources :forecasts, only: [:show]

  namespace :admin do
    resources :races, only: [:index, :update]
  end
end
