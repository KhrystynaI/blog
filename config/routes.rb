Rails.application.routes.draw do
  #resources :posts
  #get 'welcome/index'
  #resources :articles
  #root 'welcome#index'
  resources :articles do
  resources :comments
end

  end
