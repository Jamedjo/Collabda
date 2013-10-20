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
      c.build_collection
    end
  end

  def self.collection(class_name, &block)
    model = Class.new do
      include YamlData
      self.class_eval(&block)
    end
    nesting = block.binding.eval("Module.nesting[0]") || Object
    nesting.instance_eval{const_set(class_name, model)}
    model.build_collection
    return model
  end

  # def self.watch_files
  #   @classes.map{|c| c.source_path}
  # end

  InvalidSource = Class.new(StandardError)
  MissingAttributes = Class.new(StandardError)

  module ClassMethods
    def source(path, options={})
      @source_path = path
      @format = options[:type] || :yaml
      fetch_data
    end

    def all
      @yaml_models
    end

    def each(&block)
      all.each(&block)
    end

    def check_validity
      raise InvalidSource if @source_path.nil?
      raise MissingAttributes if @properties.nil?
    end

    def build_collection
      check_validity
      fetch_data
      @yaml_models = @parsed_data.map do |el|
        build(el)
      end
    end

    def build(attributes_hash)
      model = self.new
      @properties.each do |attribute|
        model.instance_variable_set("@#{attribute}",attributes_hash[attribute])
      end
      model
    end

    def properties(*attributes)
      @properties=attributes
    end

    def source_path
      @source_path
    end

    def parsed_data
      @parsed_data
    end

    private
    def fetch_data
      io = File.open(@source_path)
      @parsed_data = Readers.send(@format,io)
    end
  end

  module Readers
    def self.yaml(io)
      YAML.load(io).map{|model| model.symbolize_keys}
    end
    def self.json(io)
      JSON.load(io).map{|model| model.symbolize_keys}
    end
  end
end