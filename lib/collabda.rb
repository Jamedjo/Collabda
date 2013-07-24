require 'json'
require 'net/http'

module Collabda
  module Document
    def from_json

    end

    def property(name)
      define_method(name) do
        instance_variable_get "@#{name}"
        #fire event
      end
    end

    def source(uri)
      @@source_uri = uri
      result = Net::HTTP.get(URI.parse(uri))
    end

    private
    def self.json_to_hash(json)
      Hash[JSON.parse(json).map{|key,value| [key.to_sym, value]}]
    end
  end
end

class TestDoc
  extend Collabda::Document
  source "http://data.uniunits.co.uk/units/IIJ.json"
  property :title
  property :description

  def initialize
    @title = "test"
    @description = "this is a test"
  end
end