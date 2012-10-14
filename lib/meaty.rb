require_relative "meaty/version.rb"
require_relative "meaty/error.rb"
require "logger"
require "faraday"

module Meaty
  class Logger < ::Logger
    attr_reader :options

    def initialize(logdev, options = {})
      verify_correct_options!(options)
      formatter_class = options.fetch(:formatter, Formatter)
      synchronizer_class = options.fetch(:synchronizer, Synchronizer)

      if logdev.is_a? String
        super
      elsif logdev == :meaty
        super(nil)
        @logdev = LogDevice.new(
          options.merge({
            :synchronizer => synchronizer_class.new(options[:api_key], options)
          })
        )
      else
        super(nil)
        @logdev = logdev
      end

      @formatter = formatter_class.new
    end

    def sync
      @logdev.synchronize
    end

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
      @synchronizer = options.fetch(:synchronizer)

      mon_initialize
    end

    def write(data)
      self.synchronize do
        @buffer << data
      end

      sync if @buffer.length >= @max_buffer_size
    end

    def sync
      self.synchronize do
        @synchronizer.synchronize(@buffer)
        @buffer = []
      end
    end
  end

  class Serializer
    attr_reader :data

    def initialize(data)
      @data = data
    end

    def content_type
      "application/json"
    end

    def serialized
      @data.to_json
    end
  end

  class Synchronizer
    attr_accessor :connection

    def initialize(api_key, options)
      url = options.fetch(:url)
      @api_key = api_key
      @connection = Faraday.new(:url => url)
      @serializer_class = options.fetch(:serializer, Serializer)
    end

    def synchronize(raw_data)
      data = @serializer_class.new(raw_data)
      response = connection.post do |request|
        request.path = '/api/messages'
        request.headers['API_KEY'] = api_key
        request.headers['Content-Type'] = data.content_type
        request.body = data.serialized
      end
      { :successful => true, :response => response }
    rescue Faraday::Error::ClientError => e
      { :successful => false, :exception => e }
    end

    private
    def api_key
      @api_key
    end
  end
end

require_relative 'meaty/railtie' if defined?(Rails)
