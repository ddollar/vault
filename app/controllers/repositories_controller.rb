class RepositoriesController < ApplicationController

  skip_before_filter :load_repository
  
  def index
    @repository = Repository.default
    @repositories = Repository.list.sort
  end
  
  def show
    @repository = Repository.new(params['id'])
    redirect_to [@repository, @repository.head, @repository.head.root]
  end
  
end