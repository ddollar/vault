class NodesController < ApplicationController
  
  def index
    show
  end
  
  def show
    @revision = @repository.revision(params[:revision_id]) 
    
    params['parent_id'] ||= 'svn0'

    @load_path = params['id'] || ''

    @depth = (params['parent_id']) ? params['parent_id'].split('_').length : 1
    @node  = (@load_path != '') ? @revision.node(@load_path) : nil
    
    if @node.nil? || @node.is_directory
      directory
    else
      file
    end
  end
  
  def directory
    @nodes     = @revision.nodes(@load_path)
    
    @nodes.sort! do |a,b|
      # ugly hack
      dir_compare = b.is_directory.to_s <=> a.is_directory.to_s
      dir_compare == 0 ? a.name <=> b.name : dir_compare
    end

    respond_to do |wants|
      wants.html { render :action  => :directory }
      wants.js   { render :partial => 'nodes', 
                          :locals  => { :nodes => @nodes } }
    end

#    if request.xhr?
#      render :partial => 'show', :locals => { :nodes => @nodes }
#    else
#      render :action => :directory
#    end
  end
  
  def file
    @contents = @node.contents
    render :action => :file
  end
  
end