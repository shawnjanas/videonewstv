Videonews::Application.routes.draw do
  mount Resque::Server.new, :at => "/resque"

  devise_for :users, :controllers => { :omniauth_callbacks => "users/omniauth_callbacks" }

  root :to => "home#index"
  match '/user_ready' => 'home#user_ready'
  match '/more_videos/:page' => 'home#more_videos'
end
