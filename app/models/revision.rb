class Revision
  
  attr_accessor :repository, :author, :date, :log
  
  def initialize(id)
    @repository = repository
    @id = id || :head
    @id = :head if @id == 'head'
  end
  
  def id
    @id == :head ? @repository.latest_revision_id : @id
  end

  def node(path)
    node = @repository.node(self, path)
    node.revision = self if node  
    node
  end
  
  def root
    node = @repository.node(self, '')
  end

  def to_s
    @id.to_s
  end

end