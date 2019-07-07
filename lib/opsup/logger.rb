# frozen_string_literal: true

require 'logger'

module Opsup
  class Logger
    def self.instance
      # TODO: Enable to change the output device and the log level.
      @instance ||= ::Logger.new(STDOUT).tap do |logger|
        logger.level = ::Logger::DEBUG
      end
    end
  end
end
