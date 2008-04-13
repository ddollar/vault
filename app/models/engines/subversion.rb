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

    def revisions
      (1..latest_revision_id).collect do |revision_id|
        revision = Revision.new(revision_id)
        revision.author = @engine.fs.prop(PROP_REVISION_AUTHOR, revision_id)
        revision.date = @engine.fs.prop(PROP_REVISION_DATE, revision_id)
        revision.log = @engine.fs.prop(PROP_REVISION_LOG, revision_id)
        revision
      end.reverse
    end

    def node(revision_id, path, load_children=true)
      fs = @engine.fs
      revision_id = revision_id.to_i
      root = fs.root(revision_id)
      
      node = Node.new
      node.fullname      = path
      node.name          = File.basename(path)
      node.file_revision = root.node_created_rev(node.fullname)
      node.is_directory  = root.dir?(path)
      node.author        = fs.prop(PROP_REVISION_AUTHOR, node.file_revision).to_s
      node.date          = fs.prop(PROP_REVISION_DATE, node.file_revision)
      node.log           = fs.prop(PROP_REVISION_LOG, node.file_revision).to_s
      
      if node.is_directory
        node.size = -1
        node.contents = ''
        if load_children
          node.children = root.dir_entries(path).map do |filename, entry|
            node(revision_id, 
                 path == '' ? filename : File.join(path, filename), 
                 false)
          end
        else
          node.children = []
        end
      else
        node.size = root.file_length(path)
        node.contents = root.file_contents(path) do |stream|
          stream.read
        end
        node.children = []
      end

      node
    end
    
  end

end