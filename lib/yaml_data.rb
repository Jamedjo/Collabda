module YamlData
  def self.included(base)
    base.extend(Enumerable)
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

    def each(&block)
      @yaml_models.each(&block)
    end

    def reload
      @yaml_models = @yaml_data.map do |el|
        model = self.new
        @yaml_attributes.each do |attribute|
          model.instance_variable_set("@#{attribute}",el[attribute])
        end
        model
      end
    end

    def yaml_attributes(*attributes)
      @yaml_attributes=attributes
    end

    def yaml_path
      @yaml_path
    end

    def yaml_data
      @yaml_data
    end

    private
    def yaml_from_path(path)
      YAML.load(File.open(path)).map{|model| model.symbolize_keys}
    end
  end

end
