require 'collabda'
describe Collabda::Document do

  it "converts json string to a hash with symbols" do
    subject.send(:json_to_hash,'{"title":"test"}').should eq({:title=>"test"})
  end
end