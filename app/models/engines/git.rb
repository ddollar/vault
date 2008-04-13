require 'grit'
require 'grit/repo'

module Engines

  class Git
    
    def open(path)
      @engine = Grit::Repo.new(path)
    end
    
    def latest_revision_id
      @engine.commits.first.id_abbrev
    end
    
    def revisions
      @engine.commits.map do |commit|
        Revision.new(commit.id_abbrev)
      end
    end

    def node(revision_id, path, load_children=true)
      
      puts "RID: #{revision_id}  PATH: #{path}"
      commit = @engine.commits(revision_id).first
      tree   = commit.tree
      
      if path != ''
        path.split('/').each do |subdir|
          tree = tree / subdir
        end
      end
      
      lastcommit = Grit::Commit.list_from_string(@engine, @engine.git.log({:pretty => 'raw'}, path)).first
      
      node = Node.new
      node.fullname      = path
      node.name          = File.basename(path)
      node.file_revision = lastcommit.id_abbrev
      node.is_directory  = tree.is_a?(Grit::Tree)
      node.author        = lastcommit.author.name
      node.date          = lastcommit.authored_date
      node.log           = lastcommit.message
      
      if node.is_directory
        node.size = -1
        node.contents = ''
        if load_children
          node.children = tree.contents.map do |child|
            node(revision_id, 
                 path == '' ? child.name : File.join(path, child.name), 
                 false)
          end
        else
          node.children = []
        end
      else
        node.size = tree.size
        
        # hack to make this faster, only load contents of 'parent' node
        if load_children
          node.contents = tree.data
        else
          node.contents = ''
        end
        
        node.children = []
      end

      node
    end

  end

end