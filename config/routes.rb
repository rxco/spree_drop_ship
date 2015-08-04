Spree::Core::Engine.add_routes do

  namespace :admin do
    resource :drop_ship_settings
    resources :shipments
    resources :suppliers
  end

  get 'suppliers/connect', to: 'suppliers#connect'
  get 'suppliers/:id/verify', to: 'suppliers#verify'
  resources :suppliers
  resources :products
end
