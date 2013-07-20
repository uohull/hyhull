Hyhull::Application.routes.draw do
  root :to => "catalog#index"

  Blacklight.add_routes(self)
  HydraHead.add_routes(self)

  devise_for :users

  resources :assets
  resources :uketd_objects
  resources :journal_articles
  resources :datasets

  match 'generic_contents/initial_step', to: 'generic_contents#initial_step', via: [:get]
  resources :generic_contents

  match 'exam_papers/initial_step', to: 'exam_papers#initial_step', via: [:get]
  resources :exam_papers

  
  resources :structural_sets
  match 'structural_sets/:id/update_permissions', to: 'structural_sets#update_permissions', via: [:put]

  resources :display_sets do
    resources :exhibits, only: [:index]
  end

  match 'display_sets/:id/update_permissions', to: 'display_sets#update_permissions', via: [:put]


  resources :content_metadata
  resources :files
  resources :resource_workflow



  # Customise the assets resource to enable urls like:-
  # http://localhost:3000/assets/test:1/content
  match 'assets/:id/:datastream_id' => 'assets#show'
  

  # The priority is based upon order of creation:
  # first created -> highest priority.

  # Sample of regular route:
  #   match 'products/:id' => 'catalog#view'
  # Keep in mind you can assign values other than :controller and :action

  # Sample of named route:
  #   match 'products/:id/purchase' => 'catalog#purchase', :as => :purchase
  # This route can be invoked with purchase_url(:id => product.id)

  # Sample resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Sample resource route with options:
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

  # Sample resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Sample resource route with more complex sub-resources
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', :on => :collection
  #     end
  #   end

  # Sample resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end

  # You can have the root of your site routed with "root"
  # just remember to delete public/index.html.
  # root :to => 'welcome#index'

  # See how all your routes lay out with "rake routes"

  # This is a legacy wild controller route that's not recommended for RESTful applications.
  # Note: This route will make all actions in every controller accessible via GET requests.
  # match ':controller(/:action(/:id))(.:format)'
end
