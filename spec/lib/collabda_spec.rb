require 'collabda'

FOO_YAML = <<-yaml
- name: Foo
  description: "yo foo"
- name: Bar
  description: "at the bar"
- name: Baz
  description: "get some baz"
yaml

FOO_JSON = <<-json
[
  {"name": "FooJ", "description": "yo foo"},
  {"name": "BarJ", "description": "at the bar"},
  {"name": "BazJ", "description": "get some baz"}
]
json

describe "Collabda" do
  before(:each) do
    File.stub(:open){StringIO.open(FOO_YAML)}
  end

  let(:class_builder) do
    ->(&block) do
      -> do
        Class.new do
          include Collabda
          # include Collabda::Document
          block.call(self)
          attr_reader :description
          properties :name, :description
        end
      end
    end
  end

  let(:yaml_class_factory) do
    class_builder.call{|c| c.source "spec/lib/foo.yaml", :type=>:yaml}
  end


  it "opens specified file during class definition" do
    File.should_receive(:open)
    model_class = yaml_class_factory.call
  end

  describe "errors" do
    let(:model_class){Class.new{include Collabda}}
    it "raises InvalidSource error if source not set" do
      expect{model_class.build_collection}.to raise_error Collabda::InvalidSource
    end
    it "raises MissingAttributes error if not set" do
      model_class.source "foo.yaml"
      expect{model_class.build_collection}.to raise_error Collabda::MissingAttributes
    end
  end

  describe "Yaml model" do
    let!(:model_class){yaml_class_factory.call}
    specify "source sets a source_path class variable" do
      expect(model_class.source_path).to be_a String
    end

    specify "properties sets fields to use" do
      expect(model_class.instance_variable_get(:@properties)).to eq [:name, :description]
    end

    it "tracks where Collabda is included" do
      FooList = model_class
      expect(Collabda.instance_variable_get(:@classes)).to include FooList
    end

    # it "maintains a list of yaml files to watch" do
    #   expect(Collabda.watch_files).to include "spec/lib/foo.yaml"
    # end

    it "loads yaml data from file" do
      expect(model_class.parsed_data.count).to eq 3
    end

    it "uses symbols as attribute keys for consistency" do
      expect(model_class.parsed_data.first.keys.first).to be_a Symbol
    end

    it "builds a new model for each element in the data" do
      model_class.should_receive(:new).exactly(3).times.and_return(double(:test))
      model_class.build_collection
    end

    it "reloads the yaml file on build_collection" do
      model_class.should_receive(:fetch_data).and_call_original
      model_class.build_collection
    end

    it "can build a new instance from an attributes hash, bypassing yaml" do
      instance = model_class.build(:name=>"Bat",:description=>"man")
      expect(instance.description).to eq "man"
    end

    context "when collection built" do
      before(:each){model_class.build_collection}
      it "it provides access to all models" do
        expect(model_class.all.count).to eq 3
        expect(model_class.all.first.class).to eq model_class
      end

      it "sets instance variables for each yaml attribute" do
        expect(model_class.all.first.instance_variable_get(:@name)).to eq "Foo"
      end

      it "implements enumerable correctly" do
        expect(model_class.map{|m| m.instance_variable_get(:@name)}).to eq ["Foo","Bar","Baz"]
      end

      it "works alongside attr_reader" do
        expect(model_class.first.description).to eq "yo foo"
      end
    end
  end

  describe "Json model" do
    before(:each) do
      File.stub(:open){StringIO.open(FOO_JSON)}
    end
    let(:json_class_factory) do
      class_builder.call{|c| c.source "http://foo.bar/baz.json", :type=>:json}
    end
    it "parses json into ruby data" do
      model_class = json_class_factory.call
      expect(model_class.parsed_data.first[:name]).to eq "FooJ"
    end
  end

  describe "collection" do
    let(:built_collection) do
      Collabda.collection(:Food) do
        source ""
        properties :none
        def foo
        end
        def self.bar
        end
      end
    end

    after(:each){Object.send(:remove_const,:Food) rescue nil}

    it "creates a class in parent context" do
      built_collection = module TestModels
        class C
          Collabda.collection(:Food){source "";properties :none}
        end
      end
      expect(built_collection.to_s).to eq "TestModels::C::Food"
    end

    it "creates a class root context if not in module" do
      expect(built_collection.to_s).to eq "Food"
    end

    it "includes Collabda in the new class" do
      expect(built_collection).to respond_to :source
    end

    it "executes its block while building the class" do
      expect(built_collection).to respond_to :bar
    end

    it "executes is block in the correct context" do
      expect(built_collection.new).to respond_to :foo
    end

    it "auto-builds the collection from its source" do
      expect{Collabda.collection(:Food){}}.to raise_error Collabda::InvalidSource
    end
  end
end
