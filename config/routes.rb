SwiftbeansCms::Application.routes.draw do

  #resources :home
  #
  resources :services do
    collection do
      post :sign_in
      get :get_customer_menu
      post :save_item
      post :save_add_on
      post :update_item
      post :update_add_on
      post :open_shop
      post :update_merchant
      post :delete_item_add_ons
      get :order_detail
      get :all_order_detail
      post :update_shop_hour
      post :forgot_password
      post :accept_order
      post :change_password
      post :update_bank_account
      post :update_merchant
      post :cancel_order
      post :support_request
      post :complete_order
      post :refund_order
      get :get_notification
      get :get_analytic_main
      get :get_sales_break_down
      get :push_testing
      get :remove_pic
      post :delete_item
      post :delete_add_on
      post :save_sugar
      post :delete_sugar
      post :auto_login
      post :shop_closed
    end
  end

  resources :customer_services do
    collection do
      get :sign_in
      get :get_menu
      post :create_order
      post :add_to_favourite_shop
      post :add_to_favourite_item
      post :add_card_to_customer
      post :update_card_info
      get :get_customer_favorite_shop_items
      post :save_order
      post :update_customer
      post :forgot_password
      get :order_detail
      get :all_order_detail
      post :order_again
      post :support_request
      get :get_shop_distance_away
      post :save_rating
      get :get_shop_status
      get :get_shop_hours
      get :get_charges_ratios
    end
  end

  #resources :services do
  #  collection do
  #    get :sign_in
  #    get :sign_up
  #  end
  #end

  resources :home

  get "/super_admins" => "super_admin/home#index"
  get "/privacy_policy" => "super_admin/static_pages#privacy_policy"
  get "/terms_and_conditions_user" => "super_admin/static_pages#terms_and_conditions_user"
  get "/terms_and_conditions_merchant" => "super_admin/static_pages#terms_and_conditions_merchant"

  devise_for :users, :controllers => {
      :sessions => "users/sessions",
      :confirmation => "users/confirmations",
      :passwords => "users/passwords",
      :registrations => "users/registrations",
      :unlocks => "users/unlocks",
      :omniauth_callbacks => "users/omniauth_callbacks"
  }

  root :to => "home#index"
  devise_scope :user do
    #root :to => "users/sessions#new"
    get "sign_in" => "users/sessions#new"
    get "sign_up" => "users/registrations#new"
    get "sign_out" => "users/sessions#destroy"
    get "change_password" => "users/registrations#change_password"
    post "update_password" => "users/registrations#update_password"
    get "/super_admin" => "users/sessions#new"
    post "merchant_create" => "users/registrations#create"
    post "customer_create" => "users/registrations#create"
    get "account" => "users/registrations#edit"
  end

  namespace :super_admin do

    resources :coupon_codes do
      collection do

        post :create_setting
        get :get_users
        get :search_coupon
      end
    end


    resources :sugars do
      collection do
        get :disable_sugar
      end
    end

    resources :dashboard do
      collection do
        get :get_dashboard
        get :get_active_store
        get :get_recent_orders
      end
    end
    resources :customers do
      collection do
        get :disable_customer
      end
    end
    resources :categories do

    end
    resources :sub_categories do
      collection do
        get :disable_category
      end
    end
    resources :meta_categories
    resources :merchants  do
      collection do
      get :disable_merchant
      get :tax_ratios
      patch :update_tax_ratios
      post :verify_account
        end
    end
    resources :orders
    resources :reviews
    resources :analytics do
      collection do
        get :get_order_stats
        get :get_customer_stats
        get :break_down_by_state
        get :get_analytics
      end
    end
    resources :profiles do
      collection do
        get :profile
        put :update
      end
    end
    resources :transactions do
      collection do
        get :index
        get :charged_shop_transactions
        get :uncharged_shop_transactions
        get :charge_merchants
      end
    end
  end

  # The priority is based upon order of creation: first created -> highest priority.
  # See how all your routes lay out with "rake routes".

  # You can have the root of your site routed with "root"
  # root 'welcome#index'

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
