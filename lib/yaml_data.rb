module YamlData
  def self.included(base)
    base.extend(Enumerable)
    base.extend(ClassMethods)
    @classes ||= []
    @classes << base
  end

  def self.reload_all
    return if @classes.nil?
    @classes.each do |c|
      c.reload
    end
  end

  def self.watch_files
    @classes.map{|c| c.yaml_path}
  end

  InvalidSource = Class.new(StandardError)
  MissingAttributes = Class.new(StandardError)

  module ClassMethods
    def yaml_source(path)
      @yaml_path = path
      load_yaml_data
    end

    def all
      @yaml_models
    end

    def each(&block)
      @yaml_models.each(&block)
    end

    def reload
      raise InvalidSource if @yaml_path.nil?
      raise MissingAttributes if @yaml_attributes.nil?
      load_yaml_data
      @yaml_models = @yaml_data.map do |el|
        build(el)
      end
    end

    def build(attributes_hash)
      model = self.new
      @yaml_attributes.each do |attribute|
        model.instance_variable_set("@#{attribute}",attributes_hash[attribute])
      end
      model
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
    def load_yaml_data
      @yaml_data = YAML.load(File.open(@yaml_path)).map{|model| model.symbolize_keys}
    end
  end
end
