Rails.application.routes.draw do
  root 'races#index'

  resources :races, only: [:index, :show]
  resources :users, only: [:index, :show]
end
