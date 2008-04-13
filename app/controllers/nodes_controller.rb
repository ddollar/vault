class NodesController < ApplicationController
  
  def index
    show
  end
  
  def show
    @revision = @repository.revision(params[:revision_id]) 
    
    params['parent_id'] ||= 'svn0'

    @load_path = params['id'] || ''

    @depth = (params['parent_id']) ? params['parent_id'].split('_').length : 1
    @node  = @revision.node(@load_path)
    
    if @node.nil? || @node.is_directory
      directory
    else
      file
    end
  end
  
  def directory
    @nodes = @node.children
    
    @nodes = @nodes.sort_by do |node|
      [node.is_directory ? -1 : 1, node.name]
    end.reverse

    respond_to do |wants|
      wants.html { render :action  => :directory }
      wants.js   { render :partial => 'nodes', 
                          :locals  => { :nodes => @nodes } }
    end
  end
  
  def file
    @contents = @node.contents
    render :action => :file
  end
  
end