class Node
  
  attr_accessor :fullname, :name, :revision, :is_directory, :author, :date, 
                :log, :size, :repository, :file_revision, :contents,
                :children

  def to_s
    fullname
  end
  
end
