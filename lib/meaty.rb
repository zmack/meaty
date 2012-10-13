require_relative "meaty/version.rb"
require_relative "meaty/error.rb"
require "logger"

module Meaty
  class Logger < ::Logger
    def initialize(logdev, shift_age = 0, shift_size = 1048576)
      if logdev.is_a? String
        super
      else
        super(nil)
      end

      @logdev = logdev
      @formatter = Formatter.new
    end

    def flush; end
  end

  class Formatter
    def call(severity, time, progname, msg)
      {
        :severity => severity,
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

  def Synchronizer
    def synchronize(data)

    end
  end
end
