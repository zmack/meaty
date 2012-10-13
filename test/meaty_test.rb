require File.join(File.dirname(File.expand_path(__FILE__)), '/test_helper.rb')
require 'ostruct'

describe Meaty::Logger do
  it "should do some things" do
  end
end

describe Meaty::LogDevice do
  before do
    @device = Meaty::LogDevice.new
    @logger = Meaty::Logger.new(@device)
  end

  it "should have a functional info loglevel" do
    @device.buffer.length.must_equal 0

    @logger.info "Foobar"

    @device.buffer.length.must_equal 1
  end

  it "should have a functional warn loglevel" do
    @device.buffer.length.must_equal 0

    @logger.warn "Foobar"

    @device.buffer.length.must_equal 1
  end

  it "should have a functional error loglevel" do
    @device.buffer.length.must_equal 0

    @logger.error "Foobar"

    @device.buffer.length.must_equal 1
  end
end

describe Meaty::Synchronizer do
  before do
    @sync = Meaty::Synchronizer.new('1234', {
      :url => "http://test.bar"
    })
    @data = OpenStruct.new(:content_type => 'application/json', :serialized_data => '{ foo: "bar" }')
  end

  it "should set :successful as the marker of the outcome of the request" do
    result = @sync.synchronize(@data)
    result[:successful].must_equal false
  end
end

