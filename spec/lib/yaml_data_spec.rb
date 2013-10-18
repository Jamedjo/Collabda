require 'spec_helper'

FOO_YAML = <<-yaml
- name: Foo
  description: "yo foo"
- name: Bar
  description: "at the bar"
- name: Baz
  description: "get some baz"
yaml

describe "YamlData model" do
  before(:each) do
    File.stub(:open){StringIO.open(FOO_YAML)}
  end

  let(:new_test_class) do
    -> do
      Class.new do
        include YamlData
        yaml_source "spec/lib/foo.yaml"
        attr_reader :description
        yaml_attributes :name, :description
      end
    end
  end

  it "opens specified file during class definition" do
    File.should_receive(:open)
    model_class = new_test_class.call
  end

  describe "errors" do
    let(:model_class){Class.new{include YamlData}}
    it "raises InvalidSource error if source not set" do
      expect{model_class.reload}.to raise_error YamlData::InvalidSource
    end
    it "raises MissingAttributes error if not set" do
      model_class.yaml_source "foo.yaml"
      expect{model_class.reload}.to raise_error YamlData::MissingAttributes
    end
  end

  describe "after class definition" do
    let!(:model_class){new_test_class.call}
    specify "yaml_source sets a yaml_path class variable" do
      expect(model_class.yaml_path).to be_a String
    end

    specify "yaml_attributes sets fields to use" do
      expect(model_class.instance_variable_get(:@yaml_attributes)).to eq [:name, :description]
    end

    it "tracks where YamlData is included" do
      FooList = model_class
      expect(YamlData.instance_variable_get(:@classes).include?(FooList)).to be_true
    end

    it "maintains a list of yaml files to watch" do
      expect(YamlData.watch_files).to include "spec/lib/foo.yaml"
    end

    it "loads yaml data from file" do
      expect(model_class.yaml_data.count).to eq 3
    end

    it "uses symbols as attribute keys for consistency" do
      expect(model_class.yaml_data.first.keys.first).to be_a Symbol
    end

    it "builds a new model for each element in the data" do
      model_class.should_receive(:new).exactly(3).times.and_return(double(:test))
      model_class.reload
    end

    it "reloads the yaml file on reload" do
      model_class.should_receive(:yaml_from_path).and_call_original
      model_class.reload
    end

    it "can build a new instance from an attributes hash, bypassing yaml" do
      instance = model_class.build(:name=>"Bat",:description=>"man")
      expect(instance.description).to eq "man"
    end

    describe "after data load" do
      before(:each){model_class.reload}
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
end
