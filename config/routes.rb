Spree::Core::Engine.add_routes do

  namespace :admin do
    resource :drop_ship_settings
    resources :shipments
    resources :suppliers
  end

  namespace :api, defaults: { format: 'json' } do
    resource :sessions, controller: :user_sessions
    resources :suppliers, only: [:index, :show]
  end

  get 'suppliers/connect', to: 'suppliers#connect'
  resources :suppliers do
    member do
      get 'verify'
    end
  end
  resources :suppliers
  resources :products
end
