require 'svn/core'
require 'svn/fs'
require 'svn/repos'

module Engines
  class Subversion
    
    include Svn::Core
    
    def open(path)
      @engine = Svn::Repos.open(path)
    end

    def latest_revision_id
      @engine.youngest_rev
    end
    
    def node_contents(revision_id, name)
      @engine.fs.root(revision_id.to_i).file_contents(name) do |stream|
        stream.read
      end
    end
    
    def node(revision_id, path)
      # there has got to be a better way to do this
      new_path = File.dirname(path)
      new_path = '' if new_path == '.'
      node = nodes(revision_id, new_path).detect do |find|
        find.fullname == path
      end
    end
    
    def nodes(revision_id, path)
      fs = @engine.fs
      revision_id = revision_id.to_i
      
      root = fs.root(revision_id)
      
      @nodes = root.dir_entries(path).map do |filename, entry|
        node = Node.new
        node.fullname      = (path == '') ? filename : "#{path}/#{filename}"
        node.name          = filename.split('/').last
        node.file_revision = root.node_created_rev(node.fullname)
        node.is_directory  = entry.kind == NODE_DIR
        node.author        = fs.prop(PROP_REVISION_AUTHOR, node.file_revision).to_s
        node.date          = fs.prop(PROP_REVISION_DATE, node.file_revision)
        node.log           = fs.prop(PROP_REVISION_LOG, node.file_revision).to_s
        node.size          = entry.kind == NODE_FILE ? 
                               root.file_length(node.fullname) : ''

        node
      end  
    end
    
    def revisions
      (1..latest_revision_id).collect do |revision_id|
        Revision.new(revision_id)
      end.reverse
    end
    
    def revision_author(id)
      @engine.fs.prop(PROP_REVISION_AUTHOR, id.to_i)
    end
    
    def revision_date(id)
      @engine.fs.prop(PROP_REVISION_DATE, id.to_i)
    end

    def revision_log(id)
      @engine.fs.prop(PROP_REVISION_LOG, id.to_i)
    end
    
  end

end