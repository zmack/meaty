require File.join(File.dirname(File.expand_path(__FILE__)), '/test_helper.rb')

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

