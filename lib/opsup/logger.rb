# frozen_string_literal: true

require 'logger'

module Opsup
  class Logger
    def self.instance
      env_log_level = ENV['OPSUP_LOG_LEVEL']
      log_level =
        if env_log_level && ::Logger.const_defined?(env_log_level)
          ::Logger.const_get(env_log_level)
        else
          ::Logger::INFO
        end

      # Should be able to change the output device.
      @instance ||= ::Logger.new(STDOUT).tap do |logger|
        logger.level = log_level
      end
    end
  end
end
