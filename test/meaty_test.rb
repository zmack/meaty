require File.join(File.dirname(File.expand_path(__FILE__)), '/test_helper.rb')
require 'ostruct'

class FakeSync
  attr_accessor :api_key, :options, :url
  @instances = []

  def self.instances
    @instances
  end

  def self.add_instance(instance)
    @instances << instance
  end

  def self.reset_instances
    @instances = []
  end

  def initialize(api_key, options)
    @api_key = api_key
    @url = options[:url]
    @options = options
    self.class.add_instance(self)
  end
end

describe Meaty::Logger do
  before do
    FakeSync.reset_instances
    @logger = Meaty::Logger.new(:meaty, {
      :api_key => "1234",
      :url => "http://localhost",
      :synchronizer => FakeSync
    })
  end

  it "should pass the correct api key to the sync class" do
    FakeSync.instances.length.must_equal 1
    sync = FakeSync.instances.first
    sync.api_key.must_equal "1234"
    sync.url.must_equal "http://localhost"
  end
end

describe Meaty::LogDevice do
  before do
    @device = Meaty::LogDevice.new(:synchronizer => FakeSync.new('', {}))
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

