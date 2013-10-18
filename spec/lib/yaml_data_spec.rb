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
    File.stub(:open).and_return StringIO.open(FOO_YAML)
  end

  let(:new_test_class) do
    -> do
      Class.new do
        include YamlData
        yaml_source "spec/lib/foo.yaml"
        yaml_attributes :name, :description
      end
    end
  end

  specify "yaml_source sets a yaml_path class variable" do
    TestModel = new_test_class.call
    expect(TestModel.yaml_path).to be_a String
  end

  specify "yaml_attributes sets fields to use" do
    model_class = new_test_class.call
    expect(model_class.instance_variable_get(:@yaml_attributes)).to eq [:name, :description]
  end

  it "opens specified file on initialize" do
    File.should_receive(:open)
    TestModel2 = new_test_class.call
  end

  it "loads yaml data from file" do
    TestModel3 = new_test_class.call
    expect(TestModel3.yaml_data.count).to eq 3
  end

  it "uses symbols as attribute keys for consistency" do
    model_class = new_test_class.call
    expect(model_class.yaml_data.first.keys.first).to be_a Symbol
  end

  it "builds a new model for each element in the data" do
    TestModel4 = new_test_class.call
    TestModel4.should_receive(:new).exactly(3).times.and_return(double(:test))
    TestModel4.reload
  end

  it "it provides access to all models" do
    TestModel5 = new_test_class.call
    TestModel5.reload
    expect(TestModel5.all.count).to eq 3
    expect(TestModel5.all.first.class).to eq TestModel5
  end

  it "sets instance variables for each yaml attribute" do
    model_class = new_test_class.call
    model_class.reload
    expect(model_class.all.first.instance_variable_get(:@name)).to eq "Foo"
  end

end
