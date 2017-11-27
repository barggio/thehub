Rails.application.routes.draw do
  devise_for :users
  require 'sidekiq/web'
  mount Sidekiq::Web => '/sidekiq'    

  get '/actions/upload_file', to: 'actions#upload_file'
  get '/actions/itemsub_listing', to: 'actions#itemsub_listing'
  post '/actions/process_file', to: 'actions#process_file'
  get  '/actions/display_itemsub_result', to: 'actions#display_itemsub_result'
  get  '/actions/display_summary', to: 'actions#display_summary'
  get  '/actions/display_data_universe', to: 'actions#display_data_universe'
  get  '/actions/itemsub_validation_status', to: 'actions#itemsub_validation_status'
  get  '/session/display_catalog', to: 'actions#display_catalog'
  get  '/session/display_choose_type', to: 'actions#display_choose_type'
  post '/session/display_source_selection', to: 'actions#display_source_selection'
  post '/session/display_merge_criteria', to: 'actions#display_merge_criteria'
  post '/session/display_data', to: 'actions#display_data'
  post '/session/display_data_selection', to: 'actions#display_data_selection'
  post '/session/display_logic', to: 'actions#display_logic'
  get  '/session/delete_dataset', to: 'actions#delete_dataset'
  get  '/session/view_dataset', to: 'actions#view_dataset'
  resources :actions
  root to: "home#index"

end
