
Rails.application.routes.draw do
  resource :preferences, only: [:update]
  #get "dashboard/index"
  get "home/index"

  devise_for :users

  root "home#index"

  resources :inventories do
    member do
      get :custom_id_format
      patch :update_custom_id_format
      get :access
      get :user_search
    end
    collection do
      delete :bulk_destroy
    end

    resources :custom_fields, only: %i[create edit update destroy] do
      collection do
        post :manage
      end
    end
     resources :items, only: %i[index show new create edit update destroy] do
      collection do
        delete :bulk_destroy
        post :manage
      end
    end
    resources :inventory_accesses, only: %i[create destroy]
  end
  namespace :admin do
    resources :users, only: [:index] do
      collection do
        post :manage
      end
    end
  end
  get "dashboard", to: "dashboard#index"
  get "up" => "rails/health#show", as: :rails_health_check
end
