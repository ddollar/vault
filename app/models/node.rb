class Node
  
  attr_accessor :fullname, :name, :revision, :is_directory, :author, :date, 
                :log, :size, :repository, :file_revision
                
  def contents
    revision.node_contents(fullname)
  end
  
  def to_s
    fullname
  end
  
end
