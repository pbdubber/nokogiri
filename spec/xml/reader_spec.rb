require File.join(File.dirname(__FILE__), '..', 'helper')

include Nokogiri::XML

describe Nokogiri::XML::Reader do
  
  it "should return the correct local_names" do
    xml = <<-oexml
    <x xmlns:tenderlove='http://tenderlovemaking.com/'>
      <tenderlove:foo awesome='true'>snuggles!</tenderlove:foo>
    </x>
    oexml
    r = Reader.from_memory(xml)
    r.should_not be_nil
    r.local_name.should be_nil
    r.map{|x| x.local_name}.should == ["x","#text","foo","#text","foo","#text","x"]
  end

  it "should return the correct names" do
    reader = Nokogiri::XML::Reader.from_memory(<<-eoxml)
    <x xmlns:edi='http://ecommerce.example.org/schema'>
      <edi:foo>hello</edi:foo>
    </x>
    eoxml
    reader.should_not be_nil
    reader.name.should be_nil
    reader.map{|x| x.name}.should == ["x", "#text", "edi:foo", "#text", "edi:foo", "#text", "x"]
  end

  it "should set io as source when called from_io method" do
    io = StringIO.new(<<-eoxml)
    <x xmlns:tenderlove='http://tenderlovemaking.com/'>
      <tenderlove:foo awesome='true'>snuggles!</tenderlove:foo>
    </x>
    eoxml
    reader = Nokogiri::XML::Reader.from_io(io)
    reader.source.should be_equal(io)
  end

  it "should raise ArgumentError if nil is passed" do
    lambda{
      Nokogiri::XML::Reader.from_memory(nil)
    }.should raise_error(ArgumentError)
    lambda{
      Nokogiri::XML::Reader.from_io(nil)
    }.should raise_error(ArgumentError)
  end

  it "should parse from_io" do
    io = StringIO.new(<<-eoxml)
    <x xmlns:tenderlove='http://tenderlovemaking.com/'>
      <tenderlove:foo awesome='true'>snuggles!</tenderlove:foo>
    </x>
    eoxml
    reader = Nokogiri::XML::Reader.from_io(io)
    reader.should_not be_default
    reader.map{ |x| x.default? }.should == [false, false, false, false, false, false, false]
  end

  it "should parse when passed an io object" do
    io = StringIO.new(<<-eoxml)
    <x xmlns:tenderlove='http://tenderlovemaking.com/'>
      <tenderlove:foo awesome='true'>snuggles!</tenderlove:foo>
    </x>
    eoxml
    reader = Nokogiri::XML::Reader(io)
    reader.should_not be_default
    reader.map{ |x| x.default? }.should == [false, false, false, false, false, false, false]
  end

  it "should set string as source when called from_memory" do
    xml = <<-eoxml
    <x xmlns:tenderlove='http://tenderlovemaking.com/'>
      <tenderlove:foo awesome='true'>snuggles!</tenderlove:foo>
    </x>
    eoxml
    reader = Nokogiri::XML::Reader(xml)
    reader.source.should be_equal(xml)
  end

  it "should return false for default" do # Sorry for the description. Couldn't avoid to.
    reader = Nokogiri::XML::Reader.from_memory(<<-eoxml)
    <x xmlns:tenderlove='http://tenderlovemaking.com/'>
      <tenderlove:foo awesome='true'>snuggles!</tenderlove:foo>
    </x>
    eoxml
    reader.should_not be_default
    reader.map { |x| x.default? }.should == [false, false, false, false, false, false, false]
  end

  it "should return the correct boolean value when asked for value?" do
    reader = Nokogiri::XML::Reader.from_memory(<<-eoxml)
    <x xmlns:tenderlove='http://tenderlovemaking.com/'>
      <tenderlove:foo awesome='true'>snuggles!</tenderlove:foo>
    </x>
    eoxml

    reader.value?.should == false # Look for how should I do this in RSpec.
    reader.map {|x| x.value? }.should == [false, true, false, true, false, true, false]
  end

  it "should be able to deal with errors" do
    reader = Nokogiri::XML::Reader.from_memory(<<-eoxml)
    <x xmlns:tenderlove='http://tenderlovemaking.com/'>
      <tenderlove:foo awesome='true'>snuggles!</tenderlove:foo>
      <foo>
    </x>
    eoxml

    reader.errors.should have(0).items

    lambda {
      reader.each { |node| }
    }.should raise_error(Nokogiri::XML::SyntaxError)
 
    reader.errors.should have(1).item
  end
end
