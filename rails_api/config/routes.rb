Rails.application.routes.draw do
  get "up" => "rails/health#show", as: :rails_health_check

  scope module: :api do
    namespace :v1 do
      resources :companies do
        put :mark_deleted, on: :member
        resources :jobs do
          resources :applies, only: %i[index create]
          get "geeks", to: "geeks#index"
        end
        get "geeks", to: "geeks#index"
        get "applies", to: "applies#index"
      end

      resources :jobs do
        resources :applies, only: %i[index create]
        get "geeks", to: "geeks#index"
      end

      resources :geeks do
        put :resume, on: :member
        resources :applies, only: %i[index create]
      end

      resources :applies do
        put :read, on: :member, action: :mark_read
        put :invite, on: :member
      end
    end
  end

  match "/", to: "application#catch_404", via: :all
  match "*path", to: "application#catch_404", via: :all
end
