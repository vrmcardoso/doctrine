Rails.application.routes.draw do
  root "home#index" # <--- Public Landing Page

  resource :session
  resource :registration
  resources :passwords, param: :token

  resources :campaigns, only: [:index, :new, :create, :show]
end
