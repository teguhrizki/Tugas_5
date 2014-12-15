 Rails.application.routes.draw do
    root :to => "articles#index"
    get 'new'   => 'articles#new'
    resources :articles
    resources :comments
    resources :users
    resources :article_imports
    resources :sessions
    get "sign_up" => "users#new", :as => "sign_up"
    resources :articles do
    	collection { post :import }
    end
end