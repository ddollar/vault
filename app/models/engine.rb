class Engine
  
### CONSTANTS ##########################################################

  ENGINE_TYPES = {
    :mercurial  => 'Engines::Mercurial',
    :subversion => 'Engines::Subversion'
  }

### CLASS METHODS ######################################################
  
  def self.load(type)
    engine_type = ENGINE_TYPES[type.to_sym]
    eval("#{engine_type}.new")
  end
  
end
