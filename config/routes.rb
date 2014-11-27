Hyhull::Application.routes.draw do

  root :to => "pages#home"

  # We want to override the the Blacklight catalog route to direct to 'resources' 
  Blacklight.add_routes(self, except: [:catalog, :solr_document])
  # We don't add the Blacklight catalog/solr_document routes so that...
  # ... we can override url route with 'resources'..
  match 'resources/opensearch', to: 'catalog#opensearch',  as: 'opensearch_catalog'
  match 'resources/facet/:id', to: 'catalog#facet', as: 'catalog_facet'
  match 'resources', to: 'catalog#index', as: 'catalog_index'
  # OAI-PMH Harvesting being routes to /oai
  match 'oai', to: 'catalog#oai', as: 'oai_provider'

  resources :solr_document,  path: 'resources', controller: 'catalog', only: [:show, :update] 
  resources :catalog, path: 'resources', controller: 'catalog', only:  [:show, :update]
  # End of catalog/solr_document overides 

  HydraHead.add_routes(self)

  devise_for :users


  # Added for the Roles Management gem
  mount Hydra::RoleManagement::Engine => '/'
  get "/roles" => 'roles#index'
  # Profile resource used for user_profiles
  resources :profile

  #resources :properties

  #match 'properties_admin', to: 'property_types#index', via: [:get]
  resources :property_types do
    resources :properties
  end
  
  resources :assets
  resources :uketd_objects
  resources :journal_articles
  resources :datasets
  resources :books

  match 'generic_contents/initial_step', to: 'generic_contents#initial_step', via: [:get]
  resources :generic_contents

  match 'exam_papers/initial_step', to: 'exam_papers#initial_step', via: [:get]
  resources :exam_papers
  
  # Structural set routes
  match 'structural_sets/tree', to: 'structural_sets#tree', via: [:get]
  resources :structural_sets
  match 'structural_sets/:id/update_permissions', to: 'structural_sets#update_permissions', via: [:put]

  # Display set routes
  match 'display_sets/tree', to: 'display_sets#tree', via: [:get]

  # Removing until further development
  # match 'display_sets/exhibit/:id', to: 'display_sets#exhibit'
  resources :display_sets
  match 'display_sets/:id/update_permissions', to: 'display_sets#update_permissions', via: [:put]
  
  resources :content_metadata
  resources :files
  resources :resource_workflow


  # Customise the assets resource to enable urls like:-
  # http://localhost:3000/assets/test:1/content
  match 'assets/:id/:datastream_id' => 'assets#show'
  match 'assets/map_view/:id/:datastream_id' => 'assets#map_view'

  # Route all pages contorller actions to #/action 
  %w[home about contact cookies takedown].each do |page|
    get page, controller: 'pages', action: page
  end
  # Add health checkpage
  match 'healthcheck/rails-status' => 'pages#rails_status'

  # Mount the Hyhull modified version of Resque::Server - Use authenticate :user to ensure auth
  authenticate :user do
    mount Hyhull::Resque::AuthorisedResqueServer.new, at: '/resque'
  end

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
