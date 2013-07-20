require 'json'
module Collabda
  class Document
    def from_json

    end

    def property(name)
      define_method(name) do
        instance_variable_get "@#{name}"
        #fire event
      end
    end

    private
    def json_to_hash(json)
      Hash[JSON.parse(json).map{|key,value| [key.to_sym, value]}]
    end
  end
end