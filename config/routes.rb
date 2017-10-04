Rails.application.routes.draw do
  devise_for :users
  require 'sidekiq/web'
  mount Sidekiq::Web => '/sidekiq'    

  post '/actions/upload_file', to: 'actions#upload_file'
  get  '/actions/display_summary', to: 'actions#display_summary'
  get  '/actions/display_data_universe', to: 'actions#display_data_universe'
  resources :actions
  root to: "home#index"

end
