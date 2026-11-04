Rails.application.routes.draw do
  get "dashboard/index"
  get "home/index"
  devise_for :users
  root "home#index"
  get "dashboard", to: "dashboard#index"
  get "up" => "rails/health#show", as: :rails_health_check
end
