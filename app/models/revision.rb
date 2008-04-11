class Revision
  
  attr_accessor :repository
  
  def initialize(id)
    @repository = repository
    @id = id || :head
    @id = :head if @id == 'head'
  end
  
  def id
    @id == :head ? @repository.latest_revision_id : @id
  end

  def author
    @repository.revision_author(id)
  end
  
  def date
    @repository.revision_date(id)
  end

  def log
    @repository.revision_log(id)
  end
  
  def node_contents(path)
    @repository.node_contents(self, path)
  end
  
  def node(path)
    node = @repository.node(self, path)
    node.revision = self if node  
    node
  end
  
  def nodes(path)
    @repository.nodes(self, path).map! do |node|
      node.revision = self
      node
    end
  end
  
  def root
    node = Node.new
    node.fullname = ''
    node
  end

  def to_s
    @id.to_s
  end

end