ALLOW_DOTS ||= /[^\/]+(?=\.(html|json|ttl)\z)|[^\/]+/

Rails.application.routes.draw do
  blacklight_for :catalog
  devise_for :users
  mount Hydra::Collections::Engine => '/'
  mount CurationConcerns::Engine, at: '/'
  resources :welcome, only: :index
  root to: "welcome#index"
  iiif_for 'riiif/image', at: '/image-service'
  curation_concerns_collections
  curation_concerns_basic_routes
  curation_concerns_embargo_management
  resources :admin_sets, constraints: { id: ALLOW_DOTS } do
    member do
      get :confirm_delete
    end
  end

  # Eager load: https://github.com/resque/resque-web/issues/76
  ResqueWeb::Engine.eager_load!

  resque_web_constraint = lambda do |request|
    current_user = request.env['warden'].user
    current_user.present? && current_user.respond_to?(:groups) && current_user.groups.include?('admin')
  end

  constraints resque_web_constraint do
    mount ResqueWeb::Engine => "/resque"
  end
end
