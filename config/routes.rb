Rails.application.routes.draw do
  devise_for :users
  # The priority is based upon order of creation: first created -> highest priority.
  # See how all your routes lay out with "rake routes".

  # You can have the root of your site routed with "root"
  root 'home#index'

  get 'clubs/admin/any' => 'clubs#is_admin_for_any'
  get 'clubs/admin/:id' => 'clubs#is_admin'
  get 'clubs/admin' => 'clubs#where_admin'
  resources :clubs, only: [:index, :show, :create, :update, :destroy]
  get 'clubs/:id/admins' => 'clubs#admins'
  post 'clubs/:id/admins/:user_id' => 'clubs#add_admin'
  delete 'clubs/:id/admins/:user_id' => 'clubs#delete_admin'
  get 'clubs/:id/players' => 'clubs#players'

  resources :tournaments, only: [:show, :create, :index, :update, :destroy]

  resources :teams, only: [:show, :create, :update, :destroy]
  put 'teams/:id/add_member/:player_id' => 'teams#add_member'
  delete 'teams/:id/delete_member/:player_id' => 'teams#delete_member'
  resources :players
  # Example of regular route:
  #   get 'products/:id' => 'catalog#view'

  # Example of named route that can be invoked with purchase_url(id: product.id)
  #   get 'products/:id/purchase' => 'catalog#purchase', as: :purchase

  # Example resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Example resource route with options:
  #   resources :products do
  #     member do
  #       get 'short'
  #       post 'toggle'
  #     end
  #
  #     collection do
  #       get 'sold'
  #     end
  #   end

  # Example resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Example resource route with more complex sub-resources:
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', on: :collection
  #     end
  #   end

  # Example resource route with concerns:
  #   concern :toggleable do
  #     post 'toggle'
  #   end
  #   resources :posts, concerns: :toggleable
  #   resources :photos, concerns: :toggleable

  # Example resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end
end
