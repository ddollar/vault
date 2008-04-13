module Engines

  class Mercurial
    
    def initialize
      @manifest_cache_memo = {}
    end
    
    def open(path)
      @path = path
    end
    
    def latest_revision_id
      if execute('hg log --limit 1') =~ /changeset:\s*(\d+):([0-9a-f]+)/
        $2
      end
    end
    
    def revisions
      revisions = []
      execute('hg log').each do |line|
        if line =~ /changeset:\s*(\d+):([0-9a-f]+)/ then
          revisions << Revision.new($2)
        end
      end
      revisions
    end

    def node_contents(revision_id, name)
      execute("hg cat -r #{revision_id} #{name}")
    end
    
    def node(revision_id, path, load_children=true)
      manifest = manifest_cache(revision_id.to_i)

      puts "RID: #{revision_id}  PATH: #{path}"
      if path != ''
        path.split('/').each do |subdir|
          manifest = manifest[subdir]
        end
      end

      node = Node.new
      node.fullname      = path
      node.name          = File.basename(path)
      node.file_revision = 'TODO'
      node.is_directory  = manifest.size > 0
      node.author        = 'TODO'
      node.date          = Time.now
      node.log           = 'TODO'
      
      if node.is_directory
        node.size = -1
        node.contents = ''
        if load_children
          node.children = manifest.map do |child_filename, child_children|
            node(revision_id,
                 path == '' ?
                   child_filename : 
                   File.join(path, child_filename), 
                 false)
          end
        else
          node.children = []
        end
      else
        node.size = 'TODO'
        
        # hack to make this faster, only load contents of 'parent' node
        if load_children
          node.contents = execute("hg cat -r #{revision_id} #{path}")
        else
          node.contents = ''
        end
        
        node.children = []
      end

      node
    end

  private ################################################################
  
    def execute(command)
      IO.popen("cd #{@path} && #{command}") do |stream|
        stream.read
      end
    end
    
    def manifest_cache(revision_id)
      memo = @manifest_cache_memo[@path + revision_id.to_s]
      return memo if memo
      manifest_filename = File.join(RAILS_ROOT, 'tmp', revision_id.to_s)
      unless File.exists?(manifest_filename)
        manifest_text = execute("hg manifest #{revision_id}")
        manifest = {}
        manifest_text.each do |line|
          current = manifest
          line.chomp.split('/').each do |part|
            current = current[part] ||= {}
          end
        end

        File.open(manifest_filename, "w") do |file|
          file.puts manifest.to_yaml
        end
      end
      @manifest_cache_memo[@path + revision_id.to_s] = YAML::load_file(manifest_filename)
    end

  end

end