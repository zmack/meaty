require_relative "meaty/version.rb"
require_relative "meaty/error.rb"
require "logger"
require "faraday"

module Meaty
  class Logger < ::Logger
    attr_reader :options

    def initialize(logdev, shift_age = 0, shift_size = 1048576, options = {})
      verify_correct_options!(options)

      if logdev.is_a? String
        super
      elsif logdev == :meaty
        super(nil)
        @logdev = LogDevice.new(options)
      else
        super(nil)
        @logdev = logdev
      end

      @formatter = Formatter.new
    end

    def flush; end

  private
    def verify_correct_options!(options)
      return true if options.empty? || options.has_key?(:api_key)

      raise ArgumentError
    end
  end

  class Formatter
    def call(severity, time, progname, msg)
      {
        :severity => severity,
        :pid => $$,
        :time => time,
        :progname => progname,
        :msg => msg
      }
    end
  end

  class LogDevice
    include MonitorMixin

    attr_reader :buffer

    def initialize(options = {})
      @buffer = []
      @max_buffer_size = options.fetch(:max_buffer_size, 100)
      mon_initialize
    end

    def write(data)
      self.synchronize do
        @buffer << data
      end
    end
  end

  class Synchronizer
    attr_accessor :connection

    def initialize(api_key, options)
      url = options.fetch(:url)
      @api_key = api_key
      @connection = Faraday.new(:url => url)
    end

    def synchronize(data)
      connection.post do |request|
        request.path = '/api/messages'
        request.headers['API_KEY'] = api_key
        request.headers['Content-Type'] = data.content_type
        request.body = data.serialized
      end
      { :successful => true, :response => connection.response }
    rescue Faraday::Error::ClientError => e
      { :successful => false, :exception => e }
    end

    private
    def api_key
      @api_key
    end
  end
end
