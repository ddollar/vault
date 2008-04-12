ActionController::Routing::Routes.draw do |map|

  map.resources :repositories do |repository|
    repository.resources :revisions do |revision|
      revision.resources :nodes, :requirements => { :id => /.*/ }
    end
  end

  # default route
  map.root :controller => "repositories"

  #map.connect 'repositories/:repository_id/:controller/*id'
  
  # glob routes
  map.connect ':controller/:action/:id'
  map.connect ':controller/:action/:id.:format'
  
end
