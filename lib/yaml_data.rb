module YamlData
  def self.included(base)
    base.extend(ClassMethods)
  end

  module ClassMethods
    def yaml_source(path)
      @yaml_path = path
      File.open(path)
    end

    def yaml_path
      @yaml_path
    end
  end

end

