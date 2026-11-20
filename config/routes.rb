Rails.application.routes.draw do
  root "pages#home"

  get "missing_reports", to: "pages#missing_reports"
  get "missing_report_registration", to: "pages#missing_report_registration"
  post "missing_report_registration", to: "pages#create_missing_report"
  post "deletion_requests", to: "pages#create_deletion_request", as: :deletion_requests
  post "missing_reports", to: "pages#create_missing_report"
  get "staff_login", to: "pages#staff_login"
  post "staff_login", to: "pages#create_staff_session"
  get "lost_item_registration", to: "pages#lost_item_registration"
  post "lost_item_registration", to: "pages#create_lost_item"
  get "handover_registration", to: "pages#handover_registration"
  patch "lost_items/:id/status", to: "pages#update_lost_item_status", as: :lost_item_status
  delete "missing_reports", to: "pages#destroy_missing_report"
  delete "missing_reports/:code", to: "pages#destroy_missing_report", as: :missing_report
  delete "logout", to: "pages#destroy_staff_session", as: :logout
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/* (remember to link manifest in application.html.erb)
  # get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  # get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker

  # Defines the root path route ("/")
  # root "posts#index"
end
