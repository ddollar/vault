class ApplicationController < ActionController::Base

  protect_from_forgery

  before_filter :load_repository
  helper        :all
  layout        'standard'
  
  def load_repository
    @repository = Repository.new(
      params['repository_id'] || Repository.default_name
    )
  end
  
end
