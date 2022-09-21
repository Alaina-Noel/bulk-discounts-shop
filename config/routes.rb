Rails.application.routes.draw do

  root to: 'welcome#index'

  
  resources :merchants, except: [:show], module: 'merchant' do
    resources :invoices, only: [:index, :show]
    resources :items, except: [:destroy]
    resources :invoice_items, only: [:update]
  end
  
  get '/merchants/:merchant_id/dashboard', to: 'merchants#show'

  resources :admin, only: [:index]

  namespace :admin do
    resources :merchants
    resources :invoices, only: [:index, :show, :update]
  end
end
