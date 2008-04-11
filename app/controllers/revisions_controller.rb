class RevisionsController < ApplicationController
  
  def index
    @revisions = @repository.revisions
  end
  
  def show
    @revision = Revision.new(params['id'])
    redirect_to [@repository, @revision, @revision.root]
  end
  
end