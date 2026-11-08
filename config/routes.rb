
Rails.application.routes.draw do
  get "dashboard/index"
  get "home/index"

  devise_for :users

  root "home#index"

  resources :inventories do
    collection do
      delete :bulk_destroy
    end

    resources :custom_fields, only: %i[create edit update destroy] do
      collection do
        post :manage
      end
    end
  end
  get "dashboard", to: "dashboard#index"
  get "up" => "rails/health#show", as: :rails_health_check
end
