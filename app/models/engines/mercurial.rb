module Engines

  class Mercurial
    
    def open(path)
      @path = path
    end
    
    def session
      ApplicationController.session
    end

    def latest_revision_id
      if execute('hg log --limit 1') =~ /changeset:\s*(\d+):([0-9a-f]+)/
        $2
      end
    end
    
    def node_contents(revision_id, name)
      execute("hg cat -r #{revision_id} #{name}")
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
      @nodes = []
      current = manifest_cache(revision_id)
      path.chomp.split('/').each do |part|
        next if part == ''
        current = current[part]
      end
      if current.nil? || current.length.zero?
        current = { path.chomp.split('/').last => {} }
        path = ''
      end
      current.each do |filename, children|
        node = Node.new
        node.fullname = (path == '') ? filename : "#{path}/#{filename}"
        node.name = "#{filename}"
        node.file_revision = 'TODO'
        node.is_directory = children.length > 0
        node.author = 'TODO'
        node.date = Time.now
        node.log = 'TODO'
        node.size = 'TODO'
        @nodes << node
      end
      @nodes
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
    
    def revision_author(id)
      "TODO"
    end
    
    def revision_date(id)
      Time.now
    end

    def revision_log(id)
      "TODO"
    end
    
  private ################################################################
  
    def execute(command)
      IO.popen("cd #{@path} && #{command}") do |stream|
        stream.read
      end
    end
    
    def manifest_cache(revision_id)
      manifest_filename = File.join(RAILS_ROOT, 'tmp', revision_id)
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
      YAML::load_file(manifest_filename)
    end
    
    def commands_by_version
    end
    
  end

end