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

  # def self.watch_files
  #   @classes.map{|c| c.yaml_path}
  # end

  InvalidSource = Class.new(StandardError)
  MissingAttributes = Class.new(StandardError)

  module ClassMethods
    def source(path, options={})
      @yaml_path = path
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
      raise InvalidSource if @yaml_path.nil?
      raise MissingAttributes if @properties.nil?
    end

    def build_collection
      check_validity
      fetch_data
      @yaml_models = @yaml_data.map do |el|
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

    def yaml_path
      @yaml_path
    end

    def yaml_data
      @yaml_data
    end

    private
    def fetch_data
      io = File.open(@yaml_path)
      @yaml_data = Readers.send(@format,io)
    end
  end

  module Readers
    def self.yaml(io)
      YAML.load(io).map{|model| model.symbolize_keys}
    end
  end
end
