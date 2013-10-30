require 'json'

module Collabda
  def self.included(base)
    base.extend(Enumerable)
    base.extend(ClassMethods)
    @classes ||= []
    @classes << base
  end

  def self.rebuild_collections
    return if @classes.nil?
    @classes.each do |c|
      c.build_collection
    end
  end

  def self.collection(class_name, &block)
    model = Class.new do
      include Collabda
      self.class_eval(&block)
    end
    nesting = block.binding.eval("Module.nesting[0]") || Object
    nesting.instance_eval{const_set(class_name, model)}
    model.build_collection
    return model
  end

  def initialize(attributes_hash={})
    self.class.instance_variable_get("@properties").each do |attribute|
      instance_variable_set("@#{attribute}",attributes_hash[attribute])
    end
  end

  InvalidSource = Class.new(StandardError)
  MissingAttributes = Class.new(StandardError)

  module ClassMethods
    def source(path, options={})
      @source_path = path
      @format = options[:type] || :yaml
      fetch_data
    end

    def all
      @collabda_models
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
      @collabda_models = @parsed_data.map do |el|
        self.new(el)
      end
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

if defined? Rails
  # TODO: add development autoreload code
else
  class Hash
    def symbolize_keys
      dup.symbolize_keys!
    end
    def symbolize_keys!
      keys.each do |key|
        self[(key.to_sym rescue key) || key] = delete(key)
      end
      self
    end
  end
end