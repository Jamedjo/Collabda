module YamlData
  def self.included(base)
    base.extend(ClassMethods)
  end

  module ClassMethods
    def yaml_source(path)
      @yaml_path = path
      @yaml_data = yaml_from_path(path)
    end

    def all
      @yaml_models
    end

    def reload
      @yaml_models = @yaml_data.map{|el| self.new() }
    end

    def yaml_path
      @yaml_path
    end

    def yaml_data
      @yaml_data
    end

    private
    def yaml_from_path(path)
      YAML.load(File.open(path))
    end
  end

end
