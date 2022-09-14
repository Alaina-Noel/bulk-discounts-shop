Rails.application.routes.draw do

  resources :merchants, except: [:show] do 
    resources :invoices
    resources :items, only: [:index, :show]
  end

  get '/merchants/:merchant_id/dashboard', to: 'merchants#show'

  resources :admin, only: [:index] do
    resources :invoices, only: [:show]
  end
end
