[![Gem Version](https://badge.fury.io/rb/collabda.png)](http://badge.fury.io/rb/collabda) [![Build Status](https://travis-ci.org/Jamedjo/Collabda.png?branch=master)](https://travis-ci.org/Jamedjo/Collabda)

#Collabda

Lets you build your models from [JSON](http://en.wikipedia.org/wiki/JSON#Examples) or [YAML](http://yaml.org/) files.

    class Food
      include Collabda
      source "app/data/foo.yaml", :type=>:yaml
      properties :name, :description
      attr_reader :name
    end

    Food.build_collection

It builds an array from your data so you can do `Food.all` to get all your food objects, or `Food.map{|f| f.name}` to get all the names.

## Installation

You can just add `gem collabda` to your Gemfile or `gem install collabda`.

## Source
Specifies which file to use for this class. The file should include an array of items, each of which will become an instance of your class. 

Accepted types are `:json` and `:yaml`.

    source "app/data/bar.json", :type => :json
    
## Properties
A list of attributes which will be set as instance variables on your model.

    properties :name, :url, :count
    
    def name
      @name
    end
    
Collabda doesn't add reader methods by default- it's left to you to add them. You could write methods which use the instance variables, or you could just use `attr_reader`.
    
    attr_reader :count
    
    def link(text)
      "<a href='#{@url}'>#{text}</a>'
    end

## Collections
Once you have set up your class, you should use `YourClass.build_collection` to build instances of your class from the loaded data. Calling this reloads data from the source path, and sets each an instance variable for each property.

### Collection helper
You can use the `Collabda.collection` helper to build your classes automatically. It takes the capitalized name of your class as a symbol, and a block in which you define your class and its methods.

    Collabda.collection(:Faq) do
      source "app/data/faqs.yaml", :type=>:yaml
    
      properties :question, :answer
      attr_reader :question, :answer
    end

Its just shorthand for creating your class with `class Faq`, including Collabda, and calling `Faq.build_collection` after the class definition.

#### app/data/faqs.yaml

    - question: Why is water wet?
      answer: The feeling of wetness is actually coldness
    - question: Why don't all fish die when lightning hits the sea?
      answer: "The lightning spreads out because unlike air, water is a conductor"
    - question: How do butterflies get inside your tummy?
      answer: Ruby Magic


You can go right ahead and use `Faq.each do |faq|` to loop over all your Q&As.
    
### Rebuilding All Collections
As well as building an individual collection with `YourModel.build_collection`, you can get Collabda to rebuild all collections using `Collabda.rebuild_collections`. This is useful if you want to update all your Models after changing the files.

If you're using Rails, you can use the template in [config/initializers/collabda.rb](https://github.com/Jamedjo/Collabda/blob/master/config/initializers/collabda.rb) to auto-reload data in Rails' development mode.

### Manual build
You can directly use `YourClass.new(attributes_hash)` if you need to create an instance which doesn't use the data file. This also registers the new instance as part of the collection, so it will appear in `self.all`.

## All, Each & Enumerable
Collabda models implement [Enumerable](http://ruby-doc.org/core-2.0.0/Enumerable.html) giving you all that sugary functional magic.

    Collabda.collection :People do
      source 'app/data/people.yaml', :type => :yaml
      properties :name, :admin, :likes
    end

Favourites include `People.all`, `People.each`, `People.map`, `People.select` and `People.any?`

### Sorting & Filtering
You can use plain ruby methods from Enumerable to sort and filter your data. For example, the following will sort by likes descending:

    def self.all
      super.sort{|a,b| b.likes <=> a.likes}
    end

You can also create scopes using select:

    def self.popular
      select{|p| p.likes > 300 }
    end
    
    def admin?
        @admin || false
    end

    def self.admins
      select{|p| p.admin? }
    end


License
--------

    Copyright 2013 James Edwards-Jones

    Licensed under the Apache License, Version 2.0 (the "License");
    you may not use this file except in compliance with the License.
    You may obtain a copy of the License at

       http://www.apache.org/licenses/LICENSE-2.0

    Unless required by applicable law or agreed to in writing, software
    distributed under the License is distributed on an "AS IS" BASIS,
    WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
    See the License for the specific language governing permissions and
    limitations under the License.