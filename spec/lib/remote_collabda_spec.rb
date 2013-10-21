require 'remote_collabda'
describe Collabda::Document do

  it "converts json string to a hash with symbols" do
    subject.send(:json_to_hash,'{"title":"test"}').should eq({:title=>"test"})
  end
end

describe TestDoc do
  it "gives access to its properties" do
    subject.title.should eq "test"
    subject.description.should eq "this is a test"
  end
end