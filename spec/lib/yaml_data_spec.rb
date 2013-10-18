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
  let(:new_test_class) do
    -> do
      Class.new do
        include YamlData
        yaml_source "spec/lib/foo.yaml"
      end
    end
  end

  specify "yaml_source sets a yaml_path class variable" do
    TestModel = new_test_class.call
    expect(TestModel.yaml_path).to be_a String
  end
  it "opens specified file on initialize" do
    File.should_receive(:open)
    TestModel2 = new_test_class.call
  end

end