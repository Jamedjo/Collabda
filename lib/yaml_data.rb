module YamlData
  def self.included(base)
    base.extend(ClassMethods)
  end

  module ClassMethods
    def yaml_source(path)
      @yaml_path = path
      @yaml_models = yaml_from_path(path)
    end

    def yaml_path
      @yaml_path
    end

    def yaml_models
      @yaml_models
    end

    private
    def yaml_from_path(path)
      YAML.load(File.open(path))
    end
  end

end
