Rails.application.routes.draw do
  devise_for :users
  namespace :api do
    namespace :v1 do
      resources :users, only: [:index, :show, :create, :update, :destroy]
      resources :items, only: [:index, :show, :create, :update, :destroy]
      resources :bids, only: [:index, :show, :create, :update, :destroy]
      resources :transactions, only: [:index, :show, :create, :update, :destroy]
      resources :payments, only: [:create]
    end
  end
end
