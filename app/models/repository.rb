class Repository

### CLASS METHODS ######################################################
  
  def self.config
    YAML::load_file(CONFIG_FILE)
  end
  
  def self.default
    Repository.new(:default)
  end
  
  def self.default_name
    config['default']
  end
  
  def self.list
    config['repositories'].keys.collect { |repo| Repository.new(repo) }
  end
  
  def self.load_engines
  end
  
  def <=>(other)
    to_s<=>other.to_s
  end
  
### INSTANCE METHODS ###################################################
  
  attr_reader :name
  attr_reader :repository
  attr_reader :type
  
  def initialize(name)
    @name = (name == :default) ? Repository.default_name : name

    repository_config = Repository.config['repositories'][@name]

    @type = repository_config['type']
    @path = repository_config['path']

    @engine = Engine.load(@type)
    @engine.open(@path)
  end

  def head
    revision(:head)
  end
  
  def latest_revision_id
    @engine.latest_revision_id
  end

  def node(revision, path)
    @engine.node(revision.id, path)
  end
  
  def node_contents(revision, path)
    @engine.node_contents(revision.id, path)
  end

  def nodes(revision, path)
    @engine.nodes(revision.id, path).map! do |file|
      file.repository = self
      file
    end
  end
  
  def revision(id)
    revision = Revision.new(id)
    revision.repository = self
    revision
  end
  
  def revisions
    @engine.revisions.collect do |revision|
      revision.repository = self
      revision
    end
  end
  
  def revision_author(id)
    @engine.revision_author(id)
  end

  def revision_date(id)
    @engine.revision_date(id)
  end

  def revision_log(id)
    @engine.revision_log(id)
  end

  def to_s
    @name
  end

private ################################################################

  CONFIG_FILE = File.join(RAILS_ROOT, 'config', 'repositories.yml')
  
end