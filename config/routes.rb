Rails.application.routes.draw do
  resources :organizations do
    resources :posts
  end
  mount Ckeditor::Engine => '/ckeditor'
  
  root "organizations#index"
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
